# frozen_string_literal: true

module ImageProvider
  module Concerns
    # A concern that makes the selected resizable
    # Required methods: width_px, source_url
    module Resizable
      extend ActiveSupport::Concern

      attr_accessor :local_url

      included do
        validates :width_px, presence: true, numericality: { only_integer: true, greater_than: 0 }, allow_nil: true
        validates :source_url, presence: true
      end

      # Create the resized version
      def generate
        validate!
        return self.local_url = source_url if original?

        mm_image.resize(width_px)
        self.local_url = mm_image.path
      end

      def original?
        width_px.nil?
      end

      def mm_image
        # We keep a reference to this so that the temporary images persist for the duration of the 
        # run of the program. Not sure this is the best idea. But we'll try it.
        @mm_image ||= MiniMagick::Image.open(source_url)
      end
    end
  end
end
