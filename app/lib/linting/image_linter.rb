# frozen_string_literal: true

module Linting
  # Lints the images in a book
  class ImageLinter
    attr_reader :book

    def initialize(book:)
      @book = book
    end

    def lint
      [].tap do |annotations|
        book.sections.each do |section|
          annotations.concat(Linting::Image::Section.lint(section))
        end
      end
    end
  end
end
