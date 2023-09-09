# frozen_string_literal: true

module Linting
  module Metadata
    # Check that assessments file references point to actual files
    class AssessmentFile
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
        @file_path_list ||= content_module? ? module_assessments : video_course_assessments
      end

      def video_course_assessments
        attributes[:parts].flat_map do |part|
          part[:episodes].map do |episode|
            episode[:assessment_file]
          end
        end.compact
      end

      def module_assessments
        attributes[:lessons].flat_map do |lesson|
          ModuleFile.new(file:, attributes:).segments(lesson).flat_map do |segment|
            segment[:relative_path] if assessment?(segment)
          end
        end.compact
      end

      def content_module?
        attributes.key?(:lessons)
      end

      def assessment?(segment)
        segment[:type] == 'assessment'
      end

      # What kind of files are we looking for?
      def file_description
        'assessment'
      end
    end
  end
end
