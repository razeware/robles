# frozen_string_literal: true

module Linting
  module Image
    # Lint the image associated with a section
    class Section
      include Linting::Image::Markdown

      attr_reader :section
      delegate :markdown_file, to: :section

      def self.lint(section)
        new(section: section).lint
      end

      def initialize(section:)
        @section = section
      end

      def lint
        [].tap do |annotations|
          annotations.concat(lint_markdown_images)
          section.chapters.each do |chapter|
            annotations.concat(Linting::Image::Chapter.lint(chapter))
          end
        end
      end
    end
  end
end
