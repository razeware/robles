# frozen_string_literal: true

module Renderer
  # Methods that make it possible to attach images to objects
  module ImageAttachable
    # This object should include Concerns::MarkdownRenderable
    attr_reader :object, :image_provider

    def initialize(object, image_provider:)
      @object = object
      @image_provider = image_provider
    end

    def attach_images
      return if image_provider.blank?

      object.image_attachment_loop do |local_url|
        image_provider.representations_for_local_url(local_url)
      end
    end
  end
end
