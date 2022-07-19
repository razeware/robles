# frozen_string_literal: true

module Renderer
  # Takes an episode model, and updates it with markdown
  class Episode
    include ImageAttachable
    include MarkdownRenderable
    include Util::Logging

    attr_accessor :disable_transcripts

    def render
      logger.info "Beginning episode render: #{object.ordinal}: #{object.title}"
      attach_images
      generate_vtt_text
      render_markdown
    end

    # Extract vtt file
    def generate_vtt_text
      return if vtt.blank?

      cue_texts = vtt.cues.collect(&:text).join(' ')
      object.transcript = cue_texts
    end

    # Open vtt file
    def vtt
      @vtt ||= WebVTT.read(object.captions_file) if object.captions_file.present?
    end
  end
end
