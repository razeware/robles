# frozen_string_literal: true

module Linting
  # Run through various metadata checks
  class VideoCourseMetadataLinter
    include Util::PathExtraction

    def lint(options: {})
      [].tap do |annotations|
        annotations.concat Linting::Metadata::ReleaseAttributes.lint(file: file, attributes: release_attributes)
        annotations.concat Linting::Metadata::BranchName.lint(file: file, attributes: release_attributes, version_attribute: :version) unless options['without-version']
      end
    end

    def release_attributes
      @release_attributes ||= Psych.load_file(file).deep_symbolize_keys
    end
  end
end
