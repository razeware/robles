# frozen_string_literal: true

module Parser
  # Parses the metadata at the top of a text markdown file
  class TextMetadata
    include MarkdownMetadata

    VALID_SIMPLE_ATTRIBUTES = %i[number title description free].freeze

    attr_reader :text

    def initialize(text)
      @text = text
      @path = text.markdown_file
    end

    def apply!
      text.assign_attributes(simple_attributes)
      text.cleanse_title!
      text.authors += authors if authors.present?
    end

    def authors
      @authors ||= metadata[:authors]&.map do |author|
        Author.new(author)
      end
    end
  end
end
