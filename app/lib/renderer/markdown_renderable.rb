# frozen_string_literal: true

module Renderer
  # Methods that make it possible to render markdown from an object
  module MarkdownRenderable
    # This object should include Concerns::MarkdownRenderable
    attr_reader :object, :image_provider, :disable_transcripts

    def initialize(object, image_provider: nil)
      @object = object
      @image_provider = image_provider
    end

    def render_markdown
      object.markdown_render_loop do |content, file, vtt_file|
        file ? render_file(content, vtt_file) : render_string(content)
      end
    end

    def render_file(filename, vtt_file)
      return '' if filename.blank?

      vtt = disable_transcripts ? nil : vtt_file
      MarkdownFileRenderer.new(path: filename, image_provider:, vtt_file: vtt).render
    end

    def render_string(content)
      return '' if content.blank?

      MarkdownStringRenderer.new(content:).render
    end
  end
end
