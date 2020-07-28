# frozen_string_literal: true

module Linting
  module Markdown
    # Lint the markdown associated with a chapter
    class Chapter
      include Linting::Markdown::Renderable

      def self.lint(chapter)
        new(chapter).lint
      end

      def lint
        [].tap do |annotations|
          annotations.concat(lint_markdown_attributes)
        end
      end
    end
  end
end
