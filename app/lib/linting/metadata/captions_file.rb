# frozen_string_literal: true

module Linting
  module Metadata
    # Check that captions file references point to actual files
    class CaptionsFile
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
              episode[:captions_file]
            end
          end.compact
      end

      # What kind of files are we looking for?
      def file_description
        'captions'
      end
    end
  end
end
