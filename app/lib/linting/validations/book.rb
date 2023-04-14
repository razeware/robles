# frozen_string_literal: true

module Linting
  module Validations
    # Run the model validations for a Book and child objects
    class Book
      attr_accessor :book, :annotations, :file

      def initialize(book:, file:)
        @book = book
        @file = file
      end

      def lint # rubocop:disable Metrics/AbcSize
        [].tap do |annotations|
          book.sections.each do |section|
            section.chapters.each do |chapter|
              annotations.concat(validate_children(chapter, :authors))
            end

            annotations.concat(validate_children(section, :chapters))
          end

          annotations.concat(validate_children(book, :sections))
          annotations.concat(annotations_from_errors(book)) unless book.valid?
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
