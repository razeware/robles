# frozen_string_literal: true

module Linting
  module Metadata
    # Check that specified file attributes point to files that exist
    module FileAttributeExistenceChecker
      include Linting::FileExistenceChecker

      def file_attribute_annotations
        file_path_list.map do |path|
          next if relative_file_exists?(path)

          line = missing_file_line(path)
          Annotation.new(
            start_line: line,
            end_line: line,
            absolute_path: file,
            annotation_level: 'failure',
            message: "`release.yaml` includes references to unknown #{file_description} file: `#{path}",
            title: "Missing #{file_description} file"
          )
        end.compact
      end

      def file_path_list
        raise NotImplementedError
      end

      def file_description
        raise NotImplementedError
      end

      private

      # Check whether script file exists
      def relative_file_exists?(path)
        # Find path relative to the release.yaml file
        file_path = Pathname.new(file).dirname.join(path)
        # Check whether this exists
        file_exists?(file_path)
      end

      # Search release.yaml line by line to find the file references
      def missing_file_line(path)
        File.readlines(file).each_with_index do |line, index|
          return index + 1 if line.include?(path)
        end
      end
    end
  end
end
