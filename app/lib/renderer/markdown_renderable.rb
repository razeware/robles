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
      object.markdown_attribute = md_renderer.render
    end

    def md_renderer
      @md_renderer ||= Markdown.new(path: object.markdown_file, image_provider: image_provider)
    end
  end
end
