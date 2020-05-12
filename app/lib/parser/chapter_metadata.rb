# frozen_string_literal: true

module Parser
  # Parses the metadata at the top of a chapter markdown file
  class ChapterMetadata
    include MarkdownMetadata

    attr_reader :chapter

    def initialize(chapter)
      @chapter = chapter
      @path = chapter.markdown_file
    end

    def apply!
      chapter.number = metadata[:number]
      chapter.title = metadata[:title]
    end
  end
end
