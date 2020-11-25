# frozen_string_literal: true

module Renderer
  # Takes a sparse VideoCourse object (i.e. parsed) and renders markdown / attaches images
  class VideoCourse
    include ImageAttachable
    include MarkdownRenderable
    include Util::Logging

    def render
      logger.info 'Beginning video course render'
      attach_images
      render_markdown
      object.parts.each do |part|
        part_renderer = Renderer::Part.new(part, image_provider: image_provider)
        part_renderer.render
      end
      logger.info 'Completed video course render'
    end
  end
end
