# frozen_string_literal: true

module Parser
  # Parses a release.yaml file, and returns a VideoCourse model object
  class Release
    include Util::PathExtraction
    include Util::GitHashable

    attr_reader :video_course

    def parse
      load_course
      apply_additional_metadata
      video_course
    end

    def load_course
      @video_course = Parser::VideoCourse.new(file:).parse
    end

    def apply_additional_metadata
      video_course.root_path = root_directory
    end
  end
end
