# frozen_string_literal: true

require 'psych'

module Renderer
  # Takes a codex file and renders a book from it
  class Book
    attr_reader :codex_filename

    def initialize(codex_filename:)
      @codex_filename = codex_filename
    end

    def render
      parser.parse
    end

    def parser
      @parser ||= Parser::Codex.new(codex_filename: codex_filename)
    end
  end
end
