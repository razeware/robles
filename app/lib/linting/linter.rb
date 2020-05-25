# frozen_string_literal: true

module Linting
  # Overall linter that combines all other linters
  class Linter
    include Util::PathExtraction
    include Linting::FileExistenceChecker

    attr_reader :annotations, :output_details

    def initialize(file:)
      super
      Linting::Annotation.root_directory = Pathname.new(file).dirname
    end

    def lint(options: {})
      @annotations = []
      return output unless check_publish_file_exists

      annotations.concat(Linting::MetadataLinter.new(file: file).lint(options: options))
      return output unless annotations.blank?

      annotations.concat(Linting::ImageLinter.new(book: book).lint)

      output
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
      return true if file_exists?(file)

      @output_details = {
        title: 'robles Linting Failure',
        summary: 'Unable to locate the `publish.yaml` file',
        text: 'There should be a `publish.yaml` file in the root of your book repository.',
        validated: false
      }
      false
    end

    def book
      @book ||= begin
        parser = Parser::Publish.new(file: file)
        parser.parse
      end
    end
  end
end
