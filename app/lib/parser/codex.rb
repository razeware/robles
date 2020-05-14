# frozen_string_literal: true

module Parser
  # Parses a codex file, and returns a Book model object
  class Codex
    include Util::PathExtraction
    include Util::GitHashable

    VALID_SEGMENTS = %w[section chapter].freeze

    def parse
      sections = grouped_segments.map.with_index { |segments, idx| parse_section(segments, idx) }
      Book.new(title: codex[:title], sections: sections, git_commit_hash: git_hash)
    end

    def parse_section(segments, index)
      section_segment = segments.shift
      raise 'Invalid segment kind' unless section_segment[:kind] == 'section'

      chapters = segments.map.with_index { |segment, idx| parse_chapter(segment, idx) }
      Section.new(markdown_file: apply_path(section_segment[:path]), ordinal: index, chapters: chapters).tap do |section|
        SectionMetadata.new(section).apply!
      end
    end

    def parse_chapter(segment, index)
      raise 'Invalid semgent kind' unless segment[:kind] == 'chapter'

      Chapter.new(markdown_file: apply_path(segment[:path]), ordinal: index).tap do |chapter|
        ChapterMetadata.new(chapter).apply!
      end
    end

    private

    def codex
      @codex ||= Psych.load_file(file).deep_symbolize_keys
    end

    def grouped_segments
      codex[:segments].filter { |segment| VALID_SEGMENTS.include?(segment[:kind]) }
                      .slice_before { |segment| segment[:kind] == 'section' }
                      .filter { |group| group.first[:kind] == 'section' }
    end
  end
end
