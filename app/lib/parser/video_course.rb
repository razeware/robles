# frozen_string_literal: true

module Parser
  # Parse a symbolised hash into a VideoCourse
  class VideoCourse
    include Parser::SimpleAttributes
    include Util::PathExtraction
    include Util::GitHashable

    VALID_SIMPLE_ATTRIBUTES = %i[shortcode version version_description title course_type
                                 description_md short_description released_at materials_url
                                 professional difficulty platform language editor domains
                                 categories who_is_this_for_md covered_concepts_md git_commit_hash
                                 card_artwork_image featured_banner_image twitter_card_image].freeze

    attr_accessor :video_course

    def parse
      parts = metadata[:parts].map.with_index do |part, idx|
        parse_part(part, idx)
      end

      @video_course = ::VideoCourse.new(parts:)
      apply_episode_ordinals
      load_authors
      apply_additional_metadata
      video_course
    end

    def metadata
      @metadata = Psych.load_file(file)
                       .deep_symbolize_keys
                       .merge(git_commit_hash: git_hash)
    end

    def parse_part(metadata, index)
      episodes = metadata[:episodes].map do |episode|
        parse_episode(episode)
      end

      Part.new(ordinal: index + 1, episodes:).tap do |part|
        PartMetadata.new(part, metadata).apply!
      end
    end

    def parse_episode(metadata) # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
      script_file = apply_path(metadata[:script_file]) if metadata[:script_file].present?
      raise Parser::Error.new(file:, msg: "Script file (#{metadata[:script_file]}}) not found") if script_file.present? && !File.file?(script_file)

      root_path = Pathname.new(script_file).dirname.to_s if script_file.present?
      captions_file = apply_path(metadata[:captions_file]) if metadata[:captions_file].present?
      raise Parser::Error.new(file:, msg: "Captions file (#{metadata[:captions_file]}) not found") if captions_file.present? && !File.file?(captions_file)

      metadata[:captions_file] = captions_file if captions_file.present?
      Episode.new(script_file:, root_path:).tap do |episode|
        EpisodeMetadata.new(episode, metadata).apply!
      end
    end

    def apply_episode_ordinals
      video_course.parts.flat_map(&:episodes).each_with_index do |episode, index|
        episode.ordinal = index + 1
      end
    end

    def load_authors
      video_course.authors = Array.wrap(metadata[:authors]).map do |author|
        Author.new(author)
      end
    end

    def apply_additional_metadata
      video_course.assign_attributes(simple_attributes)
    end
  end
end
