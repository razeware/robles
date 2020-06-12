# frozen_string_literal: true

module Concerns
  # Adds a method to allow attributes to be marked as containing an image
  module ImageAttachable
    extend ActiveSupport::Concern

    included do
      class_attribute :_image_attachable_attributes, instance_writer: false, default: []
    end

    class_methods do
      # Specify the name of the attribute that the CDN image URL should be stored in
      def attr_image(attribute, source:)
        _image_attachable_attributes.push({ destination: attribute, source: source })
        attr_accessor attribute
      end
    end

    # Local paths
    def image_attachment_paths
      _image_attachable_attributes.map do |attr|
        path = send(attr[:source])
        {
          relative_path: path,
          absolute_path: (Pathname.new(root_path) + path).to_s
        }
      end
    end

    # Allows looping through the image attachment attributes, populating their remote URLs
    # Takes a block with one argument--the local URL of the file
    def image_attachment_loop(&block)
      _image_attachable_attributes.each do |attribute|
        local_url = (Pathname.new(root_path) + send(attribute[:source])).to_s
        remote_url = block.call(local_url)
        send("#{attribute[:destination]}=".to_sym, remote_url)
      end
    end
  end
end
