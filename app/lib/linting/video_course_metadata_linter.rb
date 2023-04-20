# frozen_string_literal: true

module Linting
  # Run through various metadata checks
  class VideoCourseMetadataLinter
    include Util::PathExtraction

    def lint(options: {}) # rubocop:disable Metrics/AbcSize
      [].tap do |annotations|
        annotations.concat Linting::Metadata::ReleaseAttributes.lint(file:, attributes: release_attributes)
        annotations.concat Linting::Metadata::ScriptFile.lint(file:, attributes: release_attributes)
        annotations.concat Linting::Metadata::CaptionsFile.lint(file:, attributes: release_attributes)
        annotations.concat Linting::Metadata::AssessmentFile.lint(file:, attributes: release_attributes)
        annotations.concat Linting::Metadata::BranchName.lint(file:, attributes: release_attributes, version_attribute: :version) unless options['without-version']
      end
    end

    def release_attributes
      @release_attributes ||= Psych.load_file(file, permitted_classes: [Date]).deep_symbolize_keys
    end
  end
end
