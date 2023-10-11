# frozen_string_literal: true

module Linting
  module Metadata
    # Check that captions file references point to actual files
    class CaptionsFile
      include Linting::Metadata::FileAttributeExistenceChecker
      include Parser::MarkdownMetadata

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
        @file_path_list ||= content_module? ? module_captions : video_course_captions
      end

      def video_course_captions
        attributes[:parts].flat_map do |part|
          part[:episodes].map do |episode|
            episode[:captions_file]
          end
        end.compact
      end

      # Caption file is part of markdown metadata for video and text
      # And quiz being a yaml file is handled
      def module_captions
        caption_files = ModuleFile.new(file:, attributes:).file_path_list
        caption_files.map do |file|
          captions_file = if yaml?(file)
            load_yaml(File.read(file)).deep_symbolize_keys[:captions_file]
          else
            @markdown_metadata = nil
            @path = file
            markdown_metadata[:captions_file]
          end
          next unless captions_file.present?

          [captions_file, file]
        end.compact
      end

      # What kind of files are we looking for?
      def file_description
        'captions'
      end

      private

      def yaml?(file)
        ['.yaml', '.yml'].include?(file.extname)
      end

      def content_module?
        attributes[:lessons].present?
      end
    end
  end
end
