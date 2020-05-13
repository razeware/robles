# frozen_string_literal: true

require 'psych'

module Renderer
  # Takes a codex file and renders a book from it
  class Book
    attr_reader :publish_filepath
    attr_reader :book

    def self.render(publish_filepath)
      new(publish_filepath: publish_filepath).render
    end

    def initialize(publish_filepath:)
      @publish_filepath = publish_filepath
    end

    def render
      @book = parser.parse
      book.sections.each do |section|
        section_renderer = Renderer::Section.new(section)
        section_renderer.render
      end
      book
    end

    def parser
      @parser ||= Parser::Publish.new(file: publish_filepath)
    end
  end
end
