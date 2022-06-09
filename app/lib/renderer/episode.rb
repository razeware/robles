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

    # Extract vtt file
    def generate_vtt_text
      vtt_data = vtt.read
      vtt_data.cues.each do |cue|
        logger.info object.transcript << "#{cue.text}"
        logger.info "--"
      end
    end

    # Open vtt file
    def vtt
      @vtt = WebVTT::File.open(object.captions_file) if object.captions_file.present?
    end
  end
end
