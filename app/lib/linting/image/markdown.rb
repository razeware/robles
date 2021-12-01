# frozen_string_literal: true

module Linting
  module Image
    # Find the images in a markdown file and lint them
    module Markdown
      include Linting::FileExistenceChecker

      attr_reader :markdown_file

      def lint_markdown_images
        generate_annotations(non_existent_images, :non_existent) + generate_annotations(images_missing_width, :missing_width)
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

      def message_for_image(image, type)
        if type == :non_existent
          return 'This file does not exist.' unless file_exists?(image[:absolute_path], case_insensitive: true)

          'This file does not exist. Check for case sensitivity—a very similarly named file does exist, but has different case.'
        elsif type == :missing_width
          'This image is missing a width attribute. Please provide one in the form of [width=50%]'
        end
      end

      def annotation(image, location, type)
        Linting::Annotation.new(
          location.merge(
            absolute_path: markdown_file,
            annotation_level: 'failure',
            message: message_for_image(image, type),
            title: 'Invalid image reference'
          )
        )
      end

      def generate_annotations(images, type)
        images.flat_map do |image|
          locate_errors(image[:relative_path]).map do |location|
            annotation(image, location, type)
          end
        end
      end

      def non_existent_images
        @non_existent_images ||= image_extractor.images.reject do |image|
          file_exists?(image[:absolute_path], case_insensitive: false)
        end
      end

      def images_missing_width
        @images_missing_width ||= image_extractor.images.reject do |image|
          # Either has width=x% or portrait
          width_match = /width=(\d+)%/.match(image[:alt_text])
          width_match.present? || image[:alt_text].include?('portrait')
        end
      end

      def image_extractor
        @image_extractor ||= ImageProvider::MarkdownImageExtractor.new(file: markdown_file)
      end
    end
  end
end
