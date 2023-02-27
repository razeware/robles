# frozen_string_literal: true

module Linting
  module Validations
    # Run the model validations for a VideoCourse and child objects
    class VideoCourse
      attr_accessor :video_course, :annotations, :file

      def initialize(video_course:, file:)
        @video_course = video_course
        @file = file
      end

      def lint # rubocop:disable Metrics/AbcSize
        [].tap do |annotations|
          video_course.parts.each do |part|
            part.episodes.each do |episode|
              annotations.concat(validate_children(episode, :authors))
            end

            annotations.concat(validate_children(part, :episodes))
          end

          annotations.concat(validate_children(video_course, :authors))
          annotations.concat(validate_children(video_course, :parts))

          annotations.concat(annotations_from_errors(video_course)) unless video_course.valid?
        end.compact.reverse
      end

      def validate_children(object, attribute)
        Array.wrap(object.send(attribute)).flat_map do |child|
          next if child.valid?

          annotations_from_errors(child)
        end.compact
      end

      def annotations_from_errors(object)
        title = "#{object.class} (#{object&.validation_name || 'unknown'})"
        object.errors.full_messages.map do |error|
          Linting::Annotation.new(
            start_line: 0,
            end_line: 0,
            absolute_path: file,
            annotation_level: 'failure',
            message: "#{title}: #{error}",
            title: "#{title} Validation Error"
          )
        end
      end
    end
  end
end
