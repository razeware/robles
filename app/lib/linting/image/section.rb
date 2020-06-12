# frozen_string_literal: true

module Linting
  module Image
    # Lint the image associated with a section
    class Section
      include Linting::Image::Attachable
      include Linting::Image::Markdown

      delegate :markdown_file, to: :object

      def self.lint(section)
        new(section).lint
      end

      def lint
        [].tap do |annotations|
          annotations.concat(lint_attachments)
          annotations.concat(lint_markdown_images)
          object.chapters.each do |chapter|
            annotations.concat(Linting::Image::Chapter.lint(chapter))
          end
        end
      end
    end
  end
end
