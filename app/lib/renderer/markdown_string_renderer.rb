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

      doc = CommonMarker.render_doc(
        content,
        %i[SMART STRIKETHROUGH_DOUBLE_TILDE],
        %i[table strikethrough autolink]
      )
      doc.to_html(
        %i[TABLE_PREFER_STYLE_ATTRIBUTES],
        %i[table strikethrough autolink]
      )
    end
  end
end
