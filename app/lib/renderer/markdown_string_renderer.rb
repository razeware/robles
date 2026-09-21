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
      return '' if content.blank?

      Util::Markdown.to_html(content)
    end
  end
end
