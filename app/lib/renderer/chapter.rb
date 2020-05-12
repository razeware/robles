# frozen_string_literal: true

module Renderer
  # Takes a Chapter model, and updates it with the markdown rendered into HTML
  class Chapter
    include MarkdownRenderable

    def render
      render_markdown
    end
  end
end
