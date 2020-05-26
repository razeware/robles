# frozen_string_literal: true

module Concerns
  # Adds a method that denotes which attribute should be populated with markdown
  # Use in conjunction with Renderer::MarkdownRenderable
  module MarkdownRenderable
    extend ActiveSupport::Concern

    included do
      class_attribute :_markdown_renderable_attribute, instance_writer: false
    end

    class_methods do
      # Specify the name of the attribute that markdown should be rendered into
      def attr_markdown(attribute)
        self._markdown_renderable_attribute = attribute
      end
    end

    # These instance methods are shorthand for accessing the markdown_attribute
    def markdown_attribute
      send(_markdown_renderable_attribute)
    end

    def markdown_attribute=(value)
      send("#{_markdown_renderable_attribute}=".to_sym, value)
    end
  end
end
