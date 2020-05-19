# frozen_string_literal: true

module Renderer
  # Takes a sparse Book object (i.e. parsed) and renders the markdown
  class Book
    attr_reader :book
    attr_reader :image_provider

    def initialize(book:, image_provider: nil)
      @book = book
      @image_provider = image_provider
    end

    def render
      book.sections.each do |section|
        section_renderer = Renderer::Section.new(section, image_provider: image_provider)
        section_renderer.render
      end
    end
  end
end
