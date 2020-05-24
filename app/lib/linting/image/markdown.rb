# frozen_string_literal: true

module Linting
  module Image
    # Find the images in a markdown file and lint them
    module Markdown
      include Linting::FileExistenceChecker

      attr_reader :markdown_file

      def lint_markdown_images
        non_existent_images.flat_map do |image|
          locate_errors(image[:relative_path]).map do |location|
            annotation(image, location)
          end
        end
      end

      def locate_errors(image) # rubocop:disable Metrics/MethodLength
        [].tap do |locations|
          IO.foreach(markdown_file).with_index do |line, line_number|
            next unless line.include?(image)

            start_column = line.index(image)
            locations << {
              start_line: line_number + 1,
              end_line: line_number + 1,
              start_column: start_column + 1,
              end_column: start_column + image.length + 1
            }
          end
        end
      end

      def message_for_image(image)
        return 'This file does not exist.' unless file_exists?(image[:absolute_path], case_insensitive: true)

        'This file does not exist. Check for case sensitivity—a very similarly named file does exist, but has different case.'
      end

      def annotation(image, location)
        Linting::Annotation.new(
          location.merge(
            absolute_path: markdown_file,
            annotation_level: 'failure',
            message: message_for_image(image),
            title: 'Invalid image reference'
          )
        )
      end

      def non_existent_images
        @non_existent_images ||= image_extractor.images.reject do |image|
          file_exists?(image[:absolute_path], case_insensitive: false)
        end
      end

      def image_extractor
        @image_extractor ||= ImageProvider::MarkdownImageExtractor.new(file: markdown_file)
      end
    end
  end
end
