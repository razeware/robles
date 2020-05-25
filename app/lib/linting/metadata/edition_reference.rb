# frozen_string_literal: true

module Linting
  module Metadata
    # Confirm the edition number matches the branch name
    class EditionReference
      attr_reader :file, :attributes

      def self.lint(file:, attributes:)
        new(file: file, attributes: attributes).lint
      end

      def initialize(file:, attributes:)
        @file = file
        @attributes = attributes
      end

      def lint
        return [] if current_branch == "editions/#{edition_from_metadata}"

        [error_annotation]
      end

      def current_branch
        @current_branch ||= Git.open(Pathname.new(file).dirname).current_branch
      end

      def edition_from_metadata
        @edition_from_metadata ||= attributes[:edition]
      end

      def error_annotation
        Linting::Annotation.new(
          locate_edition_reference.merge(
            absolute_path: file,
            annotation_level: 'failure',
            message: "The edition attribute in `publish.yaml` (#{edition_from_metadata}) should be the same as the one\nspecified in the git branch name (#{current_branch}).",
            title: 'Invalid edition specified'
          )
        )
      end

      def locate_edition_reference
        IO.foreach(file).with_index do |line, line_number|
          next unless line.include?('edition:')

          start_column = line.index(edition_from_metadata.to_s)
          return {
            start_line: line_number + 1,
            end_line: line_number + 1,
            start_column: start_column + 1,
            end_column: start_column + edition_from_metadata.to_s.length + 1
          }
        end
      end
    end
  end
end
