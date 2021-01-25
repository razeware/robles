# frozen_string_literal: true

module Parser
  # Parse a symbolised hash into a VideoCourse
  class VideoCourse
    include Parser::SimpleAttributes

    VALID_SIMPLE_ATTRIBUTES = %i[shortcode version version_description title course_type
                                 description_md short_description released_at materials_url
                                 professional difficulty platform language editor domains
                                 categories who_is_this_for_md covered_concepts_md git_commit_hash].freeze

    attr_accessor :video_course, :metadata

    def initialize(attributes)
      @metadata = attributes
    end

    def parse
      @video_course = ::VideoCourse.new
      load_parts
      apply_episode_ordinals
      load_authors
      apply_additional_metadata
      video_course
    end

    def load_parts
      video_course.parts = metadata[:parts].each_with_index.map do |part, index|
        Parser::Part.new(part.merge(ordinal: index + 1)).parse
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
