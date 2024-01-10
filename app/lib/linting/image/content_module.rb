# frozen_string_literal: true

module Linting
  module Image
    # Lint the images associated with a content module
    class ContentModule
      include Linting::Image::Attachable

      def self.lint(content_module)
        new(content_module).lint
      end

      def lint
        [].tap do |annotations|
          annotations.concat(lint_attachments)
          object.lessons.each do |lesson|
            annotations.concat(Linting::Image::Lesson.lint(lesson))
          end
        end
      end
    end
  end
end
