# frozen_string_literal: true

module Linting
  # Overall linter that combines all other linters
  class Linter
    include Util::PathExtraction
    include Util::Logging
    include Linting::FileExistenceChecker

    attr_reader :annotations, :output_details

    def initialize(file:)
      super
      Linting::Annotation.root_directory = Pathname.new(file).dirname
    end

    def lint(options: {})
      @annotations = []
      lint_with_ui(options: options, show_ui: !options['silent'])
      output
    end

    def lint_with_ui(options:, show_ui: true) # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
      with_spinner(title: 'Checking {{bold:publish.yaml}} exists', show: show_ui) do
        check_publish_file_exists
      end
      return if output_details.present?

      with_spinner(title: 'Validating metadata in {{bold:publish.yaml}}', show: show_ui) do
        annotations.concat(Linting::MetadataLinter.new(file: file).lint(options: options))
      end
      return unless annotations.blank?

      with_spinner(title: 'Attempting to parse book', show: show_ui) do
        book
      end
      return unless annotations.blank?

      with_spinner(title: 'Validating image references', show: show_ui) do
        annotations.concat(Linting::ImageLinter.new(book: book).lint)
      end
    end

    def with_spinner(title:, show: true)
      if show
        CLI::UI::Spinner.spin(title) { yield }
      else
        yield
      end
    end

    def output # rubocop:disable Metrics/MethodLength
      return Linting::Output.new(output_details.merge(annotations: annotations)) if output_details.present?

      if annotations.present?
        Linting::Output.new(
          title: 'robles Linting Failure',
          summary: 'There was a problem with your book repository',
          text: 'Please check the individual file annotations for details',
          annotations: annotations,
          validated: false
        )
      else
        Linting::Output.new(
          title: 'robles Linting Success',
          summary: 'Your book repo looks great',
          text: 'I have nothing else to say here...',
          validated: true
        )
      end
    end

    def check_publish_file_exists
      logger.debug "Checking for existence of #{file}"
      return true if file_exists?(file)

      @output_details = {
        title: 'robles Linting Failure',
        summary: 'Unable to locate the `publish.yaml` file',
        text: "There should be a `publish.yaml` file in the root of your book repository. Looking here: #{file}",
        validated: false
      }
      false
    end

    def book # rubocop:disable Metrics/MethodLength
      @book ||= begin
        parser = Parser::Publish.new(file: file)
        parser.parse
      end
    rescue Parser::Error => e
      line_number = (e.message.match(/at line (\d+)/)&.captures&.first&.to_i || 0) + 1
      annotations.push(
        Annotation.new(
          absolute_path: e.file,
          annotation_level: 'failure',
          start_line: line_number,
          end_line: line_number,
          message: e.message,
          title: 'Unable to parse book.'
        )
      )
    end
  end
end
