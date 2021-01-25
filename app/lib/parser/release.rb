# frozen_string_literal: true

module Parser
  # Parses a release.yaml file, and returns a VideoCourse model object
  class Release
    include Util::PathExtraction
    include Util::GitHashable

    attr_reader :video_course

    def parse
      load_course
      video_course
    end

    def load_course
      @video_course = Parser::VideoCourse.new(release_file.merge(git_commit_hash: git_hash)).parse
    end

    private

    def release_file
      @release_file ||= Psych.load_file(file).deep_symbolize_keys
    end
  end
end
