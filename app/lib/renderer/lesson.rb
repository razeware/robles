# frozen_string_literal: true

module Renderer
  # Takes a Lesson model, and updates it with markdown
  class Lesson
    include MarkdownRenderable
    include ImageAttachable
    include Util::Logging

    attr_accessor :disable_transcripts

    def render
      logger.info "Beginning lesson render: #{object.ref} #{object.title}"
      attach_images
      render_markdown
      object.segments.each do |segment|
        segment_renderer = Renderer::Segment.create(segment, image_provider:)
        segment_renderer.disable_transcripts = disable_transcripts if segment_renderer.respond_to?(:disable_transcripts=)
        segment_renderer.render
      end
    end
  end
end
