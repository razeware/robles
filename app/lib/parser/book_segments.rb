# frozen_string_literal: true

module Parser
  # Parses the segments sections of the metadata file, and returns a Book model object
  class BookSegments
    include Util::PathExtraction
    include Util::GitHashable

    VALID_SEGMENTS = %w[section chapter].freeze

    def parse
      sections = grouped_segments.map.with_index { |segments, idx| parse_section(segments, idx) }
      Book.new(title: yaml[:title], sections: sections, git_commit_hash: git_hash)
    end

    def parse_section(segments, index)
      section_segment = segments.shift
      raise 'Invalid segment kind' unless section_segment[:kind] == 'section'

      chapters = segments.map.with_index { |segment, idx| parse_chapter(segment, idx) }
      markdown_file = apply_path(section_segment[:path])
      Section.new(markdown_file: markdown_file, ordinal: index, chapters: chapters, root_path: Pathname.new(markdown_file).dirname.to_s).tap do |section|
        SectionMetadata.new(section).apply!
      end
    end

    def parse_chapter(segment, index)
      raise 'Invalid semgent kind' unless segment[:kind] == 'chapter'

      markdown_file = apply_path(segment[:path])
      Chapter.new(markdown_file: markdown_file, ordinal: index, root_path: Pathname.new(markdown_file).dirname.to_s).tap do |chapter|
        ChapterMetadata.new(chapter).apply!
      end
    end

    private

    def yaml
      @yaml ||= Psych.load_file(file).deep_symbolize_keys
    end

    def grouped_segments
      yaml[:segments].filter { |segment| VALID_SEGMENTS.include?(segment[:kind]) }
                     .slice_before { |segment| segment[:kind] == 'section' }
                     .filter { |group| group.first[:kind] == 'section' }
    end
  end
end
