# frozen_string_literal: true

module Parser
  # Parse a symbolised hash into an Episode
  class Episode
    include Parser::SimpleAttributes

    VALID_SIMPLE_ATTRIBUTES = %i[title free description_md short_description authors_notes_md].freeze

    attr_accessor :episode, :metadata

    def initialize(attributes)
      @metadata = attributes
    end

    def parse
      @episode = ::Episode.new
      load_authors
      apply_additional_metadata
      episode
    end

    def load_authors
      episode.authors = Array.wrap(metadata[:authors]).map do |author|
        Author.new(author)
      end
    end

    def apply_additional_metadata
      episode.assign_attributes(simple_attributes)
    end
  end
end
