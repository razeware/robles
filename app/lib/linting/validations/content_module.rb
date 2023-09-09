# frozen_string_literal: true

module Linting
  module Validations
    # Run the model validations for a VideoCourse and child objects
    class ContentModule
      attr_accessor :content_module, :annotations, :file

      def initialize(content_module:, file:)
        @content_module = content_module
        @file = file
      end

      def lint # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
        [].tap do |annotations|
          content_module.lessons.each do |lesson|
            lesson.segments.each do |segment|
              if segment.is_a?(Video)
                annotations.concat(validate_children(segment, :authors))
              elsif segment.is_a?(Assessment::Quiz)
                segment.questions.each do |question|
                  context = "Assessment::Quiz (#{segment&.validation_name || 'unknown'})"
                  annotations.concat(validate_children(question, :choices, context:))
                end

                annotations.concat(validate_children(segment, :questions))
              end
            end

            annotations.concat(validate_children(lesson, :segments))
          end

          annotations.concat(validate_children(content_module, :authors))
          annotations.concat(validate_children(content_module, :lessons))

          annotations.concat(annotations_from_errors(content_module)) unless content_module.valid?
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
