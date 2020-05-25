# frozen_string_literal: true

module Linting
  # Run through various metadata checks
  class MetadataLinter
    include Util::PathExtraction

    def lint
      [
        Linting::Metadata::PublishAttributes.lint(file: file, attributes: publish_attributes),
        Linting::Metadata::EditionReference.lint(file: file, attributes: publish_attributes)
      ].flatten
    end

    def publish_attributes
      @publish_attributes ||= Psych.load_file(file).deep_symbolize_keys
    end
  end
end
