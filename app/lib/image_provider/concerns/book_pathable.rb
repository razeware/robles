# frozen_string_literal: true

module ImageProvider
  module Concerns
    # A concern that creates a root path based on a book SKU
    module BookPathable
      extend ActiveSupport::Concern

      attr_accessor :sku

      included do
        validates :sku, presence: true
      end

      def uploaded_image_root_path
        validate!
        "books/#{sku}/images"
      end
    end
  end
end
