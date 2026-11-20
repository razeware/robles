# frozen_string_literal: true

module Linting
  # Warns about content that says nothing about how AI was used. A missing
  # disclosure is still valid—older content predates the policy, and nothing
  # should be blocked from publishing for it—so this is only ever a warning.
  # Problems with a disclosure that *is* present are failures, and come from the
  # model validations instead.
  #
  # Nothing is asked of a book or module released before the policy, so fixing a
  # typo in one doesn't bring a warning for every chapter. Nor of front matter:
  # dedications and team bios are exempt by kind, and any other chapter can say
  # `ai_disclosure: not_applicable`.
  class AiDisclosureLinter
    attr_reader :subject, :file

    # `subject` is a book or a content module. A module's warning is reported
    # against `file` (its module.yaml); a chapter's against its own markdown file.
    def initialize(subject:, file:)
      @subject = subject
      @file = file
    end

    def lint
      return [] if AiDisclosure.pre_policy?(subject.try(:released_at))

      records.select { |record| record.ai_disclosure_expected? && record.ai_disclosure_missing? }
             .map { |record| annotation_for(record) }
    end

    private

    def records
      return Array.wrap(subject.sections).flat_map { |section| Array.wrap(section.chapters) } if subject.respond_to?(:sections)

      Array.wrap(subject)
    end

    def annotation_for(record)
      Linting::Annotation.new(
        start_line: 0,
        end_line: 0,
        absolute_path: record.is_a?(Chapter) ? record.markdown_file : file,
        annotation_level: 'warning',
        message: "#{record.class} (#{record.validation_name || 'unknown'}) has no `ai_disclosure` block, " \
                 "so readers won't see how it was made. Add one #{where_it_goes(record)}.",
        title: 'Missing AI disclosure'
      )
    end

    def where_it_goes(record)
      return 'at the top level of module.yaml' unless record.is_a?(Chapter)

      "to the chapter's metadata block, or, if it's front matter, " \
        "write `ai_disclosure: #{AiDisclosure::NOT_APPLICABLE}` there instead"
    end
  end
end
