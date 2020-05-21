# frozen_string_literal: true

module Renderer
  # Read a file and render the markdown
  class Markdown
    include Util::Logging

    attr_reader :path
    attr_reader :image_provider

    def initialize(path:, image_provider: nil)
      @path = path
      @image_provider = image_provider
    end

    def render
      logger.debug 'Markdown::render'
      redcarpet.render(raw_content)
    end

    def raw_content
      @raw_content ||= File.read(path)
    end

    def redcarpet_renderer
      @redcarpet_renderer ||= RWMarkdownRenderer.new(with_toc_data: true,
                                                     image_provider: image_provider,
                                                     root_path: root_directory)
    end

    def redcarpet
      @redcarpet ||= Redcarpet::Markdown.new(redcarpet_renderer, tables: true, strikethrough: true, hightlight: true)
    end

    def root_directory
      @root_directory ||= Pathname.new(path).dirname
    end
  end
end
