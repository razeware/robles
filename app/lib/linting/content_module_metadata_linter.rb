# frozen_string_literal: true

module Linting
  # Run through various metadata checks
  class ContentModuleMetadataLinter
    include Util::PathExtraction

    def lint(options: {}) # rubocop:disable Metrics/AbcSize
      [].tap do |annotations|
        annotations.concat Linting::Metadata::CirculateAttributes.lint(file:, attributes: module_attributes)
        annotations.concat Linting::Metadata::ModuleFile.lint(file:, attributes: module_attributes)
        annotations.concat Linting::Metadata::CaptionsFile.lint(file:, attributes: module_attributes)
        annotations.concat Linting::Metadata::AssessmentFile.lint(file:, attributes: module_attributes)
        annotations.concat Linting::Metadata::BranchName.lint(file:, attributes: module_attributes, version_attribute: :version) unless options['without-version']
      end
    end

    def module_attributes
      @module_attributes ||= Psych.load_file(file, permitted_classes: [Date]).deep_symbolize_keys
    end
  end
end
