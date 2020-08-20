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
      CommonMarker.render_html(
        content,
        %i[SMART STRIKETHROUGH_DOUBLE_TILDE TABLE_PREFER_STYLE_ATTRIBUTES],
        %i[table strikethrough autolink]
      )
    end
  end
end
