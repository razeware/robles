# frozen_string_literal: true

module Linting
  module Metadata
    # Check for the required attributes in the publish.yaml file
    class ReleaseAttributes
      REQUIRED_ATTRIBUTES = %i[shortcode version title description_md released_at authors parts materials_url
                               version_description difficulty platform language editor professional
                               short_description domains categories ].freeze

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
            message: "`release.yaml` should include a top-level `#{missing_key}` attribute.`",
            title: 'Missing required attribute'
          )
        end
      end
    end
  end
end
