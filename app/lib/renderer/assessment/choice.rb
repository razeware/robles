# frozen_string_literal: true

module Renderer
  # Renders markdown for an assessment choice
  class Assessment::Choice
    include MarkdownRenderable
    include Util::Logging

    def render
      render_markdown
    end
  end
end
