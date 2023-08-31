# frozen_string_literal: true

module Renderer
  # Takes a sparse ContentModule object (i.e. parsed) and renders markdown / attaches images
  class ContentModule
    include ImageAttachable
    include MarkdownRenderable
    include Util::Logging

    attr_accessor :disable_transcripts

    def render
      logger.info "Beginning module render: #{object.title}"
      attach_images
      render_markdown
      object.lessons.each do |lesson|
        lesson_renderer = Renderer::Lesson.new(lesson, image_provider:)
        lesson_renderer.disable_transcripts = disable_transcripts
        lesson_renderer.render
      end
      logger.info 'Completed module render'
    end
  end
end
