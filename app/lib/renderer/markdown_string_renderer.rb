# frozen_string_literal: true

module Renderer
  # Render a string as markdown
  class MarkdownStringRenderer
    include Util::Logging

    attr_reader :content

    def initialize(content:)
      @content = content
    end

    def render
      logger.debug 'MarkdownStringRenderer::render'
      redcarpet.render(content)
    end

    def redcarpet_renderer
      @redcarpet_renderer ||= RWMarkdownRenderer.new(with_toc_data: true)
    end

    def redcarpet
      @redcarpet ||= Redcarpet::Markdown.new(redcarpet_renderer,
                                             fenced_code_blocks: true,
                                             disable_indented_code_blocks: true,
                                             autolink: true,
                                             strikethrough: true,
                                             tables: true,
                                             hightlight: true)
    end
  end
end
