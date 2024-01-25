# frozen_string_literal: true

module Linting
  # Overall linter that combines all other linters
  class VideoCourseLinter # rubocop:disable Metrics/ClassLength
    include Util::PathExtraction
    include Util::Logging
    include Linting::FileExistenceChecker
    include Linting::YamlSyntaxChecker

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

    def lint_with_ui(options:, show_ui: true) # rubocop:disable Metrics/AbcSize
      with_spinner(title: 'Checking {{bold:release.yaml}} exists', show: show_ui) do
        check_release_file_exists
      end
      return if output_details.present?

      with_spinner(title: 'Checking {{bold:release.yaml}} is valid YAML', show: show_ui) do
        check_release_file_valid_yaml
      end
      return if output_details.present?

      with_spinner(title: 'Validating metadata in {{bold:release.yaml}}', show: show_ui) do
        annotations.concat(Linting::VideoCourseMetadataLinter.new(file:).lint(options:))
      end
      return unless annotations.blank?

      with_spinner(title: 'Attempting to parse video course', show: show_ui) do
        video_course
      end
      return unless annotations.blank?

      with_spinner(title: 'Validating data models', show: show_ui) do
        annotations.concat(Linting::Validations::VideoCourse.new(video_course:, file:).lint)
      end
    end

    def with_spinner(title:, show: true, &block)
      if show
        CLI::UI::Spinner.spin(title, &block)
      else
        yield
      end
    end

    def output
      return Linting::Output.new(output_details.merge(annotations:)) if output_details.present?

      if annotations.present?
        Linting::Output.new(
          title: 'robles Linting Failure',
          summary: 'There was a problem with your video course repository',
          text: 'Please check the individual file annotations for details',
          annotations:,
          validated: false
        )
      else
        Linting::Output.new(
          title: 'robles Linting Success',
          summary: 'Your video course repo looks great',
          text: 'I have nothing else to say here...',
          validated: true
        )
      end
    end

    def check_release_file_exists
      logger.debug "Checking for existence of #{file}"
      return true if file_exists?(file)

      @output_details = {
        title: 'robles Linting Failure',
        summary: 'Unable to locate the `release.yaml` file',
        text: "There should be a `release.yaml` file in the root of your book repository. Looking here: #{file}",
        validated: false
      }
      false
    end

    def check_release_file_valid_yaml
      logger.debug "Checking for validity of #{file}"
      error = valid_yaml?(file)
      return true unless error

      @output_details = {
        title: 'robles Linting Failure',
        summary: 'Unable to parse `release.yaml`',
        text: "There was a problem parsing the `release.yaml` file. Check the indentation. Details:\n\n  > #{error}",
        validated: false
      }
      false
    end

    def video_course
      @video_course ||= begin
        parser = Parser::Release.new(file:)
        parser.parse
      end
    rescue Parser::Error => e
      line_number = e.message.match(/at line (\d+)/)&.captures&.first.to_i + 1
      annotations.push(
        Annotation.new(
          absolute_path: e.file,
          annotation_level: 'failure',
          start_line: line_number,
          end_line: line_number,
          message: e.message,
          title: 'Unable to parse video course.'
        )
      )
    end
  end
end
