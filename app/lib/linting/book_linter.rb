# frozen_string_literal: true

module Linting
  # Overall linter that combines all other linters
  class BookLinter # rubocop:disable Metrics/ClassLength
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
      lint_with_ui(options:, show_ui: !options['silent'])
      output
    end

    def lint_with_ui(options:, show_ui: true) # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
      with_spinner(title: 'Checking {{bold:publish.yaml}} exists', show: show_ui) do
        check_publish_file_exists
      end
      return if output_details.present?

      with_spinner(title: 'Validating metadata in {{bold:publish.yaml}}', show: show_ui) do
        annotations.concat(Linting::BookMetadataLinter.new(file:).lint(options:))
      end
      return unless annotations.blank?

      with_spinner(title: 'Attempting to parse book', show: show_ui) do
        book
      end
      return unless annotations.blank?

      with_spinner(title: 'Validating markdown', show: show_ui) do
        annotations.concat(Linting::MarkdownLinter.new(book:).lint)
      end

      with_spinner(title: 'Validating image references', show: show_ui) do
        annotations.concat(Linting::ImageLinter.new(book:).lint)
      end

      if file_exists?(vend_file)
        with_spinner(title: 'Validating {{bold:vend.yaml}}', show: show_ui) do
          annotations.concat(Linting::VendLinter.new(file: vend_file).lint(options:))
        end
      else
        puts CLI::UI.fmt('{{x}} Unable to find {{bold:vend.yaml}}--skipping validation.')
      end
    end

    def with_spinner(title:, show: true, &block)
      if show
        CLI::UI::Spinner.spin(title, &block)
      else
        yield
      end
    end

    def output # rubocop:disable Metrics/MethodLength
      return Linting::Output.new(output_details.merge(annotations:)) if output_details.present?

      if annotations.blank?
        Linting::Output.new(
          title: 'robles Linting Success',
          summary: 'Your book repo looks great',
          text: 'I have nothing else to say here...',
          validated: true
        )
      elsif annotations.any? { _1.annotation_level.to_sym == :failure }
        Linting::Output.new(
          title: 'robles Linting Failure',
          summary: 'There was a problem with your book repository',
          text: 'Please check the individual file annotations for details',
          annotations:,
          validated: false
        )
      else
        Linting::Output.new(
          title: 'robles Linting Results',
          summary: 'There are some warnings for your book repository',
          text: 'There are no failures—but some warnings for you to take a look at. Please check the individual file annotations for details',
          annotations:,
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

    def vend_file
      Pathname.new(file).dirname.join('vend.yaml').to_s
    end

    def book
      @book ||= begin
        parser = Parser::Publish.new(file:)
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
