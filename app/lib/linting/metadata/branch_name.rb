# frozen_string_literal: true

module Linting
  module Metadata
    # Confirm the branch name matches the appropriate attribute
    class BranchName
      attr_reader :file, :attributes, :version_attribute

      def self.lint(file:, attributes:, version_attribute:)
        new(file:, attributes:, version_attribute:).lint
      end

      def initialize(file:, attributes:, version_attribute:)
        @file = file
        @attributes = attributes
        @version_attribute = version_attribute
      end

      def lint
        return [] if current_branch == "#{version_attribute.to_s.pluralize}/#{version_from_metadata}"

        [error_annotation]
      end

      def current_branch
        @current_branch ||= Git.open(Pathname.new(file).dirname).current_branch
      end

      def version_from_metadata
        @version_from_metadata ||= attributes[version_attribute]
      end

      def error_annotation
        Linting::Annotation.new(
          locate_version_reference.merge(
            absolute_path: file,
            annotation_level: 'failure',
            message: "The #{version_attribute} attribute in #{Pathname.new(file).basename} (#{version_from_metadata}) should be the same as the one\nspecified in the git branch name (#{current_branch}).",
            title: "Invalid #{version_attribute} specified"
          )
        )
      end

      def locate_version_reference # rubocop:disable Metrics/AbcSize
        return { start_line: 0, end_line: 0 } unless attributes[version_attribute].present?

        File.foreach(file).with_index do |line, line_number|
          next unless line.include?("#{version_attribute}:")

          start_column = line.index(version_from_metadata.to_s)
          return {
            start_line: line_number + 1,
            end_line: line_number + 1,
            start_column: start_column + 1,
            end_column: start_column + version_from_metadata.to_s.length + 1
          }
        end
      end
    end
  end
end
