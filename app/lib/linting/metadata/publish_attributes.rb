# frozen_string_literal: true

module Linting
  module Metadata
    # Check for the required attributes in the publish.yaml file
    class PublishAttributes
      REQUIRED_ATTRIBUTES = %i[sku edition title description released_at authors segments materials_url].freeze

      attr_reader :file, :attributes

      def self.lint(file:, attributes:)
        new(file: file, attributes: attributes).lint
      end

      def initialize(file:, attributes:)
        @file = file
        @attributes = attributes
      end

      def lint
        (REQUIRED_ATTRIBUTES - attributes.keys).map do |missing_key|
          Annotation.new(
            start_line: 1,
            end_line: 1,
            absolute_path: file,
            annotation_level: 'failure',
            message: "`publish.yaml` should include a top-level `#{missing_key}` attribute.`",
            title: 'Missing required attribute'
          )
        end
      end
    end
  end
end
