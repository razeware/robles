# frozen_string_literal: true

module Parser
  # Parses the metadata at the top of a chapter markdown file
  class ChapterMetadata
    include MarkdownMetadata

    VALID_SIMPLE_ATTRIBUTES = %i[number title description free].freeze

    attr_reader :chapter

    def initialize(chapter)
      @chapter = chapter
      @path = chapter.markdown_file
    end

    def apply!
      chapter.assign_attributes(simple_attributes)
      chapter.cleanse_title!
      chapter.authors += authors if authors.present?
    end

    def authors
      @authors ||= metadata[:authors]&.map do |author|
        Author.new(author)
      end
    end
  end
end
