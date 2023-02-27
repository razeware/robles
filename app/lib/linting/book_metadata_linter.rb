# frozen_string_literal: true

module Linting
  # Run through various metadata checks
  class BookMetadataLinter
    include Util::PathExtraction

    def lint(options: {})
      [].tap do |annotations|
        annotations.concat Linting::Metadata::PublishAttributes.lint(file:, attributes: publish_attributes)
        annotations.concat Linting::Metadata::BranchName.lint(file:, attributes: publish_attributes, version_attribute: :edition) unless options['without-edition']
      end
    end

    def publish_attributes
      @publish_attributes ||= Psych.load_file(file, permitted_classes: [Date]).deep_symbolize_keys
    end
  end
end
