# frozen_string_literal: true

require 'psych'

module Renderer
  # Takes a codex file and renders a book from it
  class Book
    attr_reader :codex_filename
    attr_reader :book

    def initialize(codex_filename:)
      @codex_filename = codex_filename
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
      @parser ||= Parser::Codex.new(codex_filename: codex_filename)
    end
  end
end
