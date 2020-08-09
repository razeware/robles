# frozen_string_literal: true

module Linting
  module Markdown
    # Lint the markdown associated with a section
    class Section
      include Linting::Markdown::Renderable

      def self.lint(section)
        new(section).lint
      end

      def lint
        [].tap do |annotations|
          annotations.concat(lint_markdown_attributes)
          object.chapters.each do |chapter|
            annotations.concat(Linting::Markdown::Chapter.lint(chapter))
          end
        end
      end
    end
  end
end
