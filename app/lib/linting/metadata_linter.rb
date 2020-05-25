# frozen_string_literal: true

module Linting
  # Run through various metadata checks
  class MetadataLinter
    include Util::PathExtraction

    def lint(options: {})
      [].tap do |annotations|
        annotations.concat Linting::Metadata::PublishAttributes.lint(file: file, attributes: publish_attributes)
        annotations.concat Linting::Metadata::EditionReference.lint(file: file, attributes: publish_attributes) unless options['without-edition']
      end
    end

    def publish_attributes
      @publish_attributes ||= Psych.load_file(file).deep_symbolize_keys
    end
  end
end
