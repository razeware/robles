# frozen_string_literal: true

module Renderer
  # Base renderer for episodes
  class Segment
    include MarkdownRenderable
    include Util::Logging

    def self.create(model, image_provider:)
      case model
      when ::Assessment
        Renderer::Assessment.new(model, image_provider:)
      when ::Video
        Renderer::Video.new(model, image_provider:)
      when ::Text
        Renderer::Chapter.new(model, image_provider:)
      else
        raise "Unknown model type: #{model.class}"
      end
    end

    def render
      logger.info "Beginning episode render: #{object.ordinal}: #{object.title}"
      render_markdown
    end
  end
end
