# frozen_string_literal: true

module Parser
  # Parses a publish.yaml file, and returns a Book model object
  class Contributors
    include Util::PathExtraction

    attr_reader :contributors

    def parse
      process_contributors
      contributors
    end

    def process_contributors
      @contributors = contributors_file[:contributors].map do |contributor_attributes|
        Contributor.new(contributor_attributes)
      end
    end

    private

    def contributors_file
      @contributors_file ||= Psych.load_file(file).deep_symbolize_keys
    end
  end
end
