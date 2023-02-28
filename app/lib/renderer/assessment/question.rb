# frozen_string_literal: true

module Renderer
  # Renders markdown for an assessment choice
  class Assessment::Question
    include MarkdownRenderable
    include Util::Logging

    def render
      render_markdown
      object.choices.each do |choice|
        choice_renderer = Renderer::Assessment::Choice.new(choice, image_provider:)
        choice_renderer.render
      end
    end
  end
end
