# frozen_string_literal: true

module Parser
  # Parse a symbolised hash into an Episode
  class VideoMetadata
    include Parser::MarkdownMetadata

    VALID_SIMPLE_ATTRIBUTES = %i[title free description_md short_description authors_notes_md captions_file].freeze

    attr_accessor :episode

    def initialize(episode, metadata)
      @episode = episode
      @metadata = metadata
      @path = episode.script_file
    end

    def apply!
      check_captions_path
      episode.assign_attributes(simple_attributes)
      episode.authors += authors if authors.present?
    end

    def authors
      @authors ||= Array.wrap(metadata[:authors]).map do |author|
        Author.new(author)
      end
    end

    # If we've read the captions path from the script file, it needs adjusting to be absolute
    def check_captions_path
      return unless markdown_metadata&.include?(:captions_file)

      @markdown_metadata[:captions_file] = apply_path(@markdown_metadata[:captions_file])
    end

    private

    # Copied from Util::PathExtraction
    def apply_path(path)
      (root_directory + path).to_s
    end

    def root_directory
      @root_directory ||= Pathname.new(path).dirname
    end
  end
end
