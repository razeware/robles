# frozen_string_literal: true

module Renderer
  # Takes a Chapter model, and updates it with the markdown rendered into HTML
  class Chapter
    include ImageAttachable
    include MarkdownRenderable
    include Util::Logging

    def render
      logger.info "Beginning chapter render: #{object.title}"
      attach_images
      render_markdown
    end
  end
end
