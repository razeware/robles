# frozen_string_literal: true

module Parser
  # Parse a symbolised hash into a ContentModule
  class ContentModule
    include Parser::SimpleAttributes
    include Parser::AiDisclosureAttributes
    include Util::PathExtraction
    include Util::GitHashable
    include Parser::ContentRoot

    VALID_SIMPLE_ATTRIBUTES = %i[shortcode version version_description title
                                 description_md short_description released_at materials_url
                                 professional difficulty platform language editor domains
                                 categories who_is_this_for_md module_outcomes_md covered_concepts_md git_commit_hash
                                 featured_banner_image twitter_card_image
                                 access_personal access_team module_type].freeze

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

    # Memoised: every caller re-reading module.yaml also spawned a `git log`
    # subprocess. It also means the captions_file path that `parse_video` makes
    # absolute now survives, which is what that assignment always intended.
    def metadata
      @metadata ||= load_yaml_file(content_file!(file, kind: 'module file', named_in: file)).merge(git_commit_hash: git_hash)
    end

    def parse_lesson(metadata, index)
      segments = parse_segments(metadata[:segments_path])

      Lesson.new(ordinal: index + 1, segments:).tap do |lesson|
        lesson_metadata = lesson_yaml(metadata[:segments_path])
        LessonMetadata.new(lesson, lesson_metadata).apply!
      end
    end

    def parse_segments(segment_yaml_file)
      lesson_path = Pathname.new(segment_yaml_file).dirname.to_s
      lesson = lesson_yaml(segment_yaml_file)

      lesson[:segments].map do |segment|
        segment_path = "#{lesson_path}/#{segment[:path]}"
        send(:"parse_#{segment[:type]}", segment_path, named_in: apply_path(segment_yaml_file))
      end
    end

    def parse_text(file, named_in:)
      markdown_file = content_file!(apply_path(file), kind: 'text', named_in:)

      Text.new(markdown_file:, root_path: Pathname.new(markdown_file).dirname.to_s).tap do |text|
        TextMetadata.new(text).apply!
      end
    end

    def parse_video(file, named_in:) # rubocop:disable Metrics/AbcSize
      script_file = content_file!(apply_path(file), kind: 'script', named_in:) if file.present?
      root_path = Pathname.new(script_file).dirname.to_s if script_file.present?
      captions_file = apply_path(metadata[:captions_file]) if metadata[:captions_file].present?
      metadata[:captions_file] = captions_file if captions_file.present?
      Video.new(script_file:, root_path:).tap do |video|
        VideoMetadata.new(video, metadata).apply!
        check_captions!(video, captions_file)
      end
    end

    def parse_assessment(file, named_in:)
      assessment_file = content_file!(apply_path(file), kind: 'assessment', named_in:) if file.present?
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
      content_module.assign_attributes(ai_disclosure_attributes)
    end

    private

    def load_yaml_file(file)
      Psych.load_file(file, permitted_classes: [Date]).deep_symbolize_keys
    end

    def lesson_yaml(segments_path)
      load_yaml_file(content_file!(apply_path(segments_path), kind: 'lesson file', named_in: file))
    end

    # Captions named in the script's metadata block win over those in module.yaml
    def check_captions!(video, yaml_captions_file)
      return if video.captions_file.blank?

      named_in = video.captions_file == yaml_captions_file ? file : video.script_file
      content_file!(video.captions_file, kind: 'captions file', named_in:)
    end
  end
end
