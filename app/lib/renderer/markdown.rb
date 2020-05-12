# frozen_string_literal: true

module Renderer
  # Read a file and render the markdown
  class Markdown
    attr_reader :path

    def initialize(path:)
      @path = path
    end

    def render
      redcarpet.render(raw_content)
    end

    def raw_content
      @raw_content ||= File.read(path)
    end

    def redcarpet_renderer
      @redcarpet_renderer ||= Redcarpet::Render::HTML.new(with_toc_data: true)
    end

    def redcarpet
      @redcarpet ||= Redcarpet::Markdown.new(redcarpet_renderer, tables: true, strikethrough: true, hightlight: true, )
    end
  end
end
