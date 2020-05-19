# frozen_string_literal: true

module Renderer
  # Takes a Section model, and updates it with the markdown (of the chapters) rendered into HTML
  class Section
    include MarkdownRenderable

    def render
      render_markdown
      object.chapters.each do |chapter|
        chapter_renderer = Renderer::Chapter.new(chapter, image_provider: image_provider)
        chapter_renderer.render
      end
    end
  end
end
