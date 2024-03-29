# frozen_string_literal: true

module Linting
  module Metadata
    # Check that script file references point to actual files
    class ScriptFile
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
          attributes[:parts].flat_map do |part|
            part[:episodes].map do |episode|
              episode[:script_file]
            end
          end.compact
      end

      # What kind of files are we looking for?
      def file_description
        'script'
      end
    end
  end
end
