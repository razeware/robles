# frozen_string_literal: true

module Linting
  # Lints the markdown in a book
  class MarkdownLinter
    attr_reader :book

    def initialize(book:)
      @book = book
    end

    def lint
      Linting::Markdown::Book.lint(book)
    end
  end
end
