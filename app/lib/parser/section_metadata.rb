# frozen_string_literal: true

module Parser
  # Parses the metadata at the top of a section markdown file
  class SectionMetadata
    include MarkdownMetadata

    attr_reader :section

    def initialize(section)
      @section = section
      @path = section.markdown_file
    end

    def apply!
      section.number = metadata[:number]
      section.title = metadata[:title]
    end
  end
end
