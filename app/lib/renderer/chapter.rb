# frozen_string_literal: true

module Renderer
  # Takes a Chapter model, and updates it with the markdown rendered into HTML
  class Chapter
    include MarkdownRenderable
    include Util::Logging

    def render
      logger.info "Beginning chapter render: #{object.title}"
      render_markdown
    end
  end
end
