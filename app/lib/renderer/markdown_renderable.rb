# frozen_string_literal: true

module Renderer
  # Methods that make it possible to render markdown from an object
  module MarkdownRenderable
    # This object should include Concerns::MarkdownRenderable
    attr_accessor :object

    def initialize(object)
      @object = object
    end

    def render_markdown
      object.markdown_attribute = md_renderer.render
    end

    def md_renderer
      @md_renderer ||= Markdown.new(path: object.markdown_file)
    end
  end
end
