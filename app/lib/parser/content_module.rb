# frozen_string_literal: true

module Parser
  # Parse a symbolised hash into a ContentModule
  class ContentModule
    include Parser::SimpleAttributes
    include Util::PathExtraction
    include Util::GitHashable

    VALID_SIMPLE_ATTRIBUTES = %i[shortcode version version_description title
                                 description_md short_description released_at materials_url
                                 professional difficulty platform language editor domains
                                 categories who_is_this_for_md covered_concepts_md git_commit_hash
                                 card_artwork_image featured_banner_image twitter_card_image
                                 access_personal access_team].freeze

    attr_accessor :content_module

    def parse
      lessons = metadata[:lessons].map.with_index do |lesson, idx|
        parse_lesson(lesson, idx)
      end

      @content_module = ::ContentModule.new(lessons:)
      apply_segment_ordinals
      load_authors
      apply_additional_metadata
      content_module
    end

    def metadata
      @metadata = load_yaml_file(file).merge(git_commit_hash: git_hash)
    end

    def parse_lesson(metadata, index)
      segments = parse_segments(metadata[:segments_path])

      Lesson.new(ordinal: index + 1, segments:).tap do |lesson|
        lesson_metadata = load_yaml_file(apply_path((metadata[:segments_path])))
        LessonMetadata.new(lesson, lesson_metadata).apply!
      end
    end

    def parse_segments(segment_yaml_file)
      lesson_path = segment_yaml_file.split('/').first
      lesson = load_yaml_file(apply_path(segment_yaml_file))

      lesson[:segments].map do |segment|
        segment_path = "#{lesson_path}/#{segment[:path]}"
        send("parse_#{segment[:type]}".to_sym, segment_path)
      end
    end

    def parse_text(file)
      markdown_file = apply_path(file)

      Text.new(markdown_file:, root_path: Pathname.new(markdown_file).dirname.to_s).tap do |text|
        TextMetadata.new(text).apply!
      end
    end

    def parse_video(file) # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
      script_file = apply_path(file) if file.present?
      raise Parser::Error.new(file:, msg: "Script file (#{file}}) not found") if script_file.present? && !File.file?(script_file)

      root_path = Pathname.new(script_file).dirname.to_s if script_file.present?
      captions_file = apply_path(metadata[:captions_file]) if metadata[:captions_file].present?
      raise Parser::Error.new(file:, msg: "Captions file (#{metadata[:captions_file]}) not found") if captions_file.present? && !File.file?(captions_file)

      metadata[:captions_file] = captions_file if captions_file.present?
      Video.new(script_file:, root_path:).tap do |video|
        VideoMetadata.new(video, metadata).apply!
      end
    end

    def parse_assessment(file)
      assessment_file = apply_path(file) if file.present?
      raise Parser::Error.new(file:, msg: "Assessment file (#{file}}) not found") if assessment_file.present? && !File.file?(assessment_file)

      assessment_metadata = load_yaml_file(assessment_file)

      Assessment.create(assessment_metadata).tap do |assessment|
        AssessmentMetadata.new(assessment, assessment_metadata).apply!
      end
    end

    def apply_segment_ordinals
      content_module.lessons.flat_map(&:segments).each_with_index do |segment, index|
        segment.ordinal = index + 1
      end

      # ref is reset for each lesson
      content_module.lessons.each do |lesson|
        lesson.segments.each_with_index do |segment, index|
          segment.ref ||= (index + 1).to_s.rjust(2, '0')
        end
      end
    end

    def load_authors
      content_module.authors = Array.wrap(metadata[:authors]).map do |author|
        Author.new(author)
      end
    end

    def apply_additional_metadata
      content_module.assign_attributes(simple_attributes)
    end

    private

    def load_yaml_file(file)
      Psych.load_file(file, permitted_classes: [Date]).deep_symbolize_keys
    end
  end
end
