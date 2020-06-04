# frozen_string_literal: true

module Parser
  # Parses the metadata at the top of a section markdown file
  class SectionMetadata
    include MarkdownMetadata

    VALID_SIMPLE_ATTRIBUTES = %i[number title].freeze

    attr_reader :section

    def initialize(section)
      @section = section
      @path = section.markdown_file
    end

    def apply!
      section.assign_attributes(simple_attributes)
      section.cleanse_title!
    end
  end
end
