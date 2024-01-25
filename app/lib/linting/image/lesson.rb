# frozen_string_literal: true

module Linting
  module Image
    # Lint the image associated with a lesson
    class Lesson
      include Linting::Image::Attachable

      def self.lint(lesson)
        new(lesson).lint
      end

      def lint
        [].tap do |annotations|
          annotations.concat(lint_attachments)
          object.segments.each do |segment|
            annotations.concat(Linting::Image::Segment.lint(segment))
          end
        end
      end
    end
  end
end
