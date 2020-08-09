# frozen_string_literal: true

module Linting
  module Image
    # Find the images in a markdown file and lint them
    module Attachable
      include Linting::FileExistenceChecker

      attr_reader :object

      def initialize(object)
        @object = object
      end

      def lint_attachments
        non_existent_images.flat_map do |image|
          locate_errors(image[:relative_path]).map do |location|
            annotation(image, location)
          end
        end
      end

      def locate_errors(_image)
        [{
          start_line: 1,
          end_line: 1
        }]
      end

      def message_for_image(image)
        return 'This file does not exist.' unless file_exists?(image[:absolute_path], case_insensitive: true)

        'This file does not exist. Check for case sensitivity—a very similarly named file does exist, but has different case.'
      end

      def annotation(image, location)
        Linting::Annotation.new(
          location.merge(
            absolute_path: '/data/src/publish.yaml', # WARNING: This is hardcoded and should probably be re-done
            annotation_level: 'failure',
            message: message_for_image(image),
            title: 'Invalid image reference'
          )
        )
      end

      def non_existent_images
        @non_existent_images ||= object.image_attachment_paths.reject do |image|
          file_exists?(image[:absolute_path], case_insensitive: false)
        end
      end
    end
  end
end
