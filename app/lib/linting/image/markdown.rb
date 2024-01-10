# frozen_string_literal: true

module Linting
  module Image
    # Find the images in a markdown file and lint them
    module Markdown
      include Linting::FileExistenceChecker

      attr_reader :markdown_file

      def lint_markdown_images(check_width: true)
        annotations = _md_generate_annotations(_md_non_existent_images, :non_existent)
        return annotations unless check_width

        annotations + _md_generate_annotations(_md_images_missing_width, :missing_width)
      end

      private

      def _md_locate_errors(image)
        [].tap do |locations|
          File.foreach(markdown_file).with_index do |line, line_number|
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

      def _md_message_for_image(image, type)
        case type
        when :non_existent
          return "This file (#{image[:relative_path]}) does not exist." unless file_exists?(image[:absolute_path], case_insensitive: true)

          "This file (#{image[:relative_path]}) does not exist. Check for case sensitivity—a very similarly named file does exist, but has different case."
        when :missing_width
          "This image (#{image[:relative_path]}) is missing a width attribute. Please provide one in the form of [width=50%]"
        end
      end

      def _md_annotation(image, location, type)
        Linting::Annotation.new(
          location.merge(
            absolute_path: markdown_file,
            annotation_level: 'failure',
            message: _md_message_for_image(image, type),
            title: 'Invalid image reference'
          )
        )
      end

      def _md_generate_annotations(images, type)
        images.flat_map do |image|
          _md_locate_errors(image[:relative_path]).map do |location|
            _md_annotation(image, location, type)
          end
        end
      end

      def _md_non_existent_images
        @_md_non_existent_images ||= _md_image_extractor.images.reject do |image|
          file_exists?(image[:absolute_path], case_insensitive: false)
        end
      end

      def _md_images_missing_width
        @_md_images_missing_width ||= _md_image_extractor.images.reject do |image|
          # Either has width=x% or portrait
          width_match = /width=(\d+)%/.match(image[:alt_text])
          width_match.present? || image[:alt_text].include?('portrait')
        end
      end

      def _md_image_extractor
        @_md_image_extractor ||= ImageProvider::MarkdownImageExtractor.new(file: markdown_file)
      end
    end
  end
end
