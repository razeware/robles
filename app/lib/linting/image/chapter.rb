# frozen_string_literal: true

module Linting
  module Image
    # Lint the images associated with a chapter
    class Chapter
      include Linting::Image::Markdown

      attr_reader :chapter
      delegate :markdown_file, to: :chapter

      def self.lint(chapter)
        new(chapter: chapter).lint
      end

      def initialize(chapter:)
        @chapter = chapter
      end

      def lint
        lint_markdown_images
      end
    end
  end
end
