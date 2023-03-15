# frozen_string_literal: true

module Renderer
  # Takes an assessment model, and updates it with markdown
  class Assessment < Episode
    def render
      super
      object.questions.each do |question|
        question_renderer = Renderer::Assessment::Question.new(question, image_provider:)
        question_renderer.render
      end
    end
  end
end
