# frozen_string_literal: true

module Parser
  # Parse a symbolised hash into an Episode
  class EpisodeMetadata
    include Parser::MarkdownMetadata

    VALID_SIMPLE_ATTRIBUTES = %i[title free description_md short_description authors_notes_md captions_file].freeze

    attr_accessor :episode

    def initialize(episode, metadata)
      @episode = episode
      @metadata = metadata
      @path = episode.script_file
    end

    def apply!
      episode.assign_attributes(simple_attributes)
      episode.authors += authors if authors.present?
    end

    def authors
      @authors ||= Array.wrap(metadata[:authors]).map do |author|
        Author.new(author)
      end
    end
  end
end
