# frozen_string_literal: true

module Concerns
  # Adds methods to allow attributes to be marked as containing markdown
  module MarkdownRenderable
    extend ActiveSupport::Concern

    included do
      class_attribute :_markdown_renderable_attributes, instance_writer: false, default: []
    end

    class_methods do
      # Specify the name of the attribute that markdown should be rendered into
      def attr_markdown(attribute, source:, file: false, wrapper_class: nil)
        _markdown_renderable_attributes.push({ destination: attribute, source: source, file: file, wrapper_class: wrapper_class })
        attr_accessor attribute
      end
    end

    # Allows a renderer to loop through the different markdown fields, rendering them.
    # Takes a block with two arguments--content & file
    def markdown_render_loop(&block)
      _markdown_renderable_attributes.each do |attribute|
        content = send(attribute[:source])
        rendered = block.call(content, attribute[:file])
        rendered = wrap_render(rendered, attribute[:wrapper_class])

        send("#{attribute[:destination]}=".to_sym, rendered)
      end
    end

    def wrap_render(rendered, wrapper_class)
      class_string = if wrapper_class.is_a?(Symbol) && respond_to?(wrapper_class)
                       send(wrapper_class)
                     elsif wrapper_class.is_a?(String)
                       wrapper_class
                     end
      return rendered unless class_string.is_a?(String)

      %(
      <div class="#{class_string}">
        #{rendered}
      </div>
      )
    end
  end
end
