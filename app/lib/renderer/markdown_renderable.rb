# frozen_string_literal: true

module Renderer
  # Methods that make it possible to render markdown from an object
  module MarkdownRenderable
    attr_accessor :object

    def initialize(object)
      @object = object
    end

    def render_markdown
      object.body = md_renderer.render
    end

    def md_renderer
      @md_renderer ||= Markdown.new(path: object.markdown_file)
    end
  end
end
