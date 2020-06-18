# frozen_string_literal: true

module Linting
  module Image
    # Lint the images associated with a chapter
    class Chapter
      include Linting::Image::Attachable
      include Linting::Image::Markdown

      delegate :markdown_file, to: :object

      def self.lint(chapter)
        new(chapter).lint
      end

      def lint
        [].tap do |annotations|
          annotations.concat(lint_attachments)
          annotations.concat(lint_markdown_images)
        end
      end
    end
  end
end
