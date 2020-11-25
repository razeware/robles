# frozen_string_literal: true

module Renderer
  # Takes an episode model, and updates it with markdown
  class Episode
    include ImageAttachable
    include MarkdownRenderable
    include Util::Logging

    def render
      logger.info "Beginning episode render: #{object.ordinal}: #{object.title}"
      attach_images
      render_markdown
    end
  end
end
