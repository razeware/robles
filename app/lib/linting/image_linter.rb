# frozen_string_literal: true

module Linting
  # Lints the images in a book or a content_module
  class ImageLinter
    attr_reader :book, :content_module

    def initialize(book: nil, content_module: nil)
      @book = book
      @content_module = content_module
    end

    def lint
      return Linting::Image::Book.lint(book) if book.present?

      Linting::Image::ContentModule.lint(content_module) if content_module.present?
    end
  end
end
