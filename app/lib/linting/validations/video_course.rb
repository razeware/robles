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

      def lint # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
        [].tap do |annotations|
          video_course.parts.each do |part|
            part.episodes.each do |episode|
              if episode.is_a?(Video)
                annotations.concat(validate_children(episode, :authors))
              elsif episode.is_a?(Assessment::Quiz)
                episode.questions.each do |question|
                  context = "Assessment::Quiz (#{episode&.validation_name || 'unknown'})"
                  annotations.concat(validate_children(question, :choices, context:))
                end

                annotations.concat(validate_children(episode, :questions))
              end
            end

            annotations.concat(validate_children(part, :episodes))
          end

          annotations.concat(validate_children(video_course, :authors))
          annotations.concat(validate_children(video_course, :parts))

          annotations.concat(annotations_from_errors(video_course)) unless video_course.valid?
        end.compact.reverse
      end

      def validate_children(object, attribute, context: nil)
        Array.wrap(object.send(attribute)).flat_map do |child|
          next if child.valid?

          context = "#{context}\n#{object.class} (#{object&.validation_name || 'unknown'})"
          annotations_from_errors(child, context:)
        end.compact
      end

      def annotations_from_errors(object, context: nil)
        title = "#{object.class} (#{object&.validation_name || 'unknown'})"
        object.errors.full_messages.map do |error|
          Linting::Annotation.new(
            start_line: 0,
            end_line: 0,
            absolute_path: file,
            annotation_level: 'failure',
            message: "#{context}\n#{title}: #{error}",
            title: "#{title} Validation Error"
          )
        end
      end
    end
  end
end
