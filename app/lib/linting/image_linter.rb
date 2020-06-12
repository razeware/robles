# frozen_string_literal: true

module Linting
  # Lints the images in a book
  class ImageLinter
    attr_reader :book

    def initialize(book:)
      @book = book
    end

    def lint
      Linting::Image::Book.lint(book)
    end
  end
end
