# frozen_string_literal: true

module Parser
  # Parses a codex file, and returns a Book model object
  class Codex
    VALID_SEGMENTS = %w[section chapter].freeze

    attr_reader :codex_filename

    def initialize(codex_filename:)
      @codex_filename = codex_filename
    end

    def parse
      sections = grouped_segments.map.with_index { |segments, idx| parse_section(segments, idx) }
      Book.new(title: codex[:title], sections: sections)
    end

    def parse_section(segments, index)
      section_segment = segments.shift
      raise 'Invalid segment kind' unless section_segment[:kind] == 'section'

      chapters = segments.map.with_index { |segment, idx| parse_chapter(segment, idx) }
      Section.new(markdown_file: section_segment[:path], number: index, chapters: chapters)
    end

    def parse_chapter(segment, index)
      raise 'Invalid semgent kind' unless segment[:kind] == 'chapter'

      Chapter.new(markdown_file: segment[:path], number: index)
    end

    private

    def codex
      @codex ||= Psych.load_file(codex_filename).deep_symbolize_keys
    end

    def grouped_segments
      codex[:segments].filter { |segment| VALID_SEGMENTS.include?(segment[:kind]) }
                      .slice_before { |segment| segment[:kind] == 'section' }
                      .filter { |group| group.first[:kind] == 'section' }
    end
  end
end
