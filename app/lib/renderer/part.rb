# frozen_string_literal: true

module Renderer
  # Takes a Part model, and updates it with markdown
  class Part
    include MarkdownRenderable
    include ImageAttachable
    include Util::Logging

    attr_accessor :disable_transcripts

    def render
      logger.info "Beginning part render: #{object.title}"
      attach_images
      render_markdown
      object.episodes.each do |episode|
        episode_renderer = Renderer::Episode.new(episode, image_provider: image_provider)
        episode_renderer.disable_transcripts = disable_transcripts
        episode_renderer.render
      end
    end
  end
end
