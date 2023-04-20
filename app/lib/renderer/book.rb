# frozen_string_literal: true

module Renderer
  # Takes a sparse Book object (i.e. parsed) and renders the markdown
  class Book
    include ImageAttachable
    include MarkdownRenderable
    include Util::Logging

    def render
      logger.info 'Beginning book render'
      attach_images
      render_markdown
      object.sections.each do |section|
        section_renderer = Renderer::Section.new(section, image_provider:)
        section_renderer.render
      end
      logger.info 'Completed book render'
    end
  end
end
