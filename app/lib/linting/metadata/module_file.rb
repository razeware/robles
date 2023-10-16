# frozen_string_literal: true

module Linting
  module Metadata
    # Check that script file references point to actual files
    class ModuleFile
      include Linting::Metadata::FileAttributeExistenceChecker

      attr_reader :file, :attributes

      def self.lint(file:, attributes:)
        new(file:, attributes:).lint
      end

      def initialize(file:, attributes:)
        @file = file
        @attributes = attributes
      end

      def lint
        file_attribute_annotations
      end

      # Find the script file references in each episode in the release.yaml
      def file_path_list
        @file_path_list ||=
          attributes[:lessons].flat_map do |lesson|
            segment_files(lesson)
          end.compact
      end

      def segments(lesson)
        @file_path = Pathname.new(file).dirname.join(lesson[:segments_path])
        lesson_data = Psych.load_file(@file_path, permitted_classes: [Date]).deep_symbolize_keys
        lesson_data[:segments].map do |segment|
          segment[:relative_path] = Pathname.new(@file_path).dirname.join(segment[:path])
          segment
        end
      end

      def segment_files(lesson)
        segments(lesson).map { |segment| segment[:relative_path] }
      end

      # What kind of files are we looking for?
      def file_description
        'script'
      end
    end
  end
end
