# frozen_string_literal: true

module Linting
  module Markdown
    # Lint the markdown associated with a book
    class Book
      include Linting::Markdown::Renderable

      def self.lint(book)
        new(book).lint
      end

      def lint
        [].tap do |annotations|
          annotations.concat(lint_markdown_attributes)
          object.sections.each do |section|
            annotations.concat(Linting::Markdown::Section.lint(section))
          end
        end
      end
    end
  end
end
