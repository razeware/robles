# frozen_string_literal: true

module Renderer
  # Methods that make it possible to render markdown from an object
  module MarkdownRenderable
    # This object should include Concerns::MarkdownRenderable
    attr_reader :object, :image_provider

    def initialize(object, image_provider: nil)
      @object = object
      @image_provider = image_provider
    end

    def render_markdown
      object.markdown_render_loop do |content, file|
        file ? render_file(content) : render_string(content)
      end
    end

    def render_file(filename)
      MarkdownFileRenderer.new(path: filename, image_provider: image_provider).render
    end

    def render_string(content)
      MarkdownStringRenderer.new(content: content).render
    end
  end
end
