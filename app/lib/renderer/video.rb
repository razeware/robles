# frozen_string_literal: true

module Renderer
  # Takes an video model, and updates it with markdown & images
  class Video < Episode
    include ImageAttachable

    attr_accessor :disable_transcripts

    def render
      super
      attach_images
      generate_vtt_text
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
