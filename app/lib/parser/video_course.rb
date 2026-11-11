# frozen_string_literal: true

module Parser
  # Parse a symbolised hash into a VideoCourse
  class VideoCourse
    include Parser::SimpleAttributes
    include Util::PathExtraction
    include Util::GitHashable
    include Parser::ContentRoot

    VALID_SIMPLE_ATTRIBUTES = %i[shortcode version version_description title course_type
                                 description_md short_description released_at materials_url
                                 professional difficulty platform language editor domains
                                 categories who_is_this_for_md covered_concepts_md git_commit_hash
                                 card_artwork_image featured_banner_image twitter_card_image
                                 access_personal access_team].freeze

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
      @metadata = Psych.load_file(content_file!(file, kind: 'release file', named_in: file), permitted_classes: [Date])
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

    def parse_episode(metadata)
      if metadata[:assessment_file].present?
        parse_assessment(metadata)
      else
        parse_video(metadata)
      end
    end

    def parse_video(metadata) # rubocop:disable Metrics/AbcSize
      script_file = content_file!(apply_path(metadata[:script_file]), kind: 'script', named_in: file) if metadata[:script_file].present?
      root_path = Pathname.new(script_file).dirname.to_s if script_file.present?
      captions_file = apply_path(metadata[:captions_file]) if metadata[:captions_file].present?
      metadata[:captions_file] = captions_file if captions_file.present?
      Video.new(script_file:, root_path:).tap do |video|
        VideoMetadata.new(video, metadata).apply!
        check_captions!(video, captions_file)
      end
    end

    def parse_assessment(metadata)
      assessment_file = content_file!(apply_path(metadata[:assessment_file]), kind: 'assessment', named_in: file) if metadata[:assessment_file].present?
      assessment_metadata = Psych.load_file(assessment_file, permitted_classes: [Date]).deep_symbolize_keys.merge(metadata)

      Assessment.create(assessment_metadata).tap do |assessment|
        AssessmentMetadata.new(assessment, assessment_metadata).apply!
      end
    end

    def apply_episode_ordinals
      video_course.parts.flat_map(&:episodes).each_with_index do |episode, index|
        episode.ordinal = index + 1
        episode.ref ||= episode.ordinal.to_s.rjust(2, '0')
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

    private

    # Captions named in the script's metadata block win over those in release.yaml
    def check_captions!(video, yaml_captions_file)
      return if video.captions_file.blank?

      named_in = video.captions_file == yaml_captions_file ? file : video.script_file
      content_file!(video.captions_file, kind: 'captions file', named_in:)
    end
  end
end
