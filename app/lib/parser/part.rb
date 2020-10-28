# frozen_string_literal: true

module Parser
  # Parse a symbolised hash into a Part, with nested Episodes
  class Part
    include Parser::SimpleAttributes

    VALID_SIMPLE_ATTRIBUTES = %i[title description ordinal].freeze

    attr_accessor :part, :metadata

    def initialize(attributes)
      @metadata = attributes
    end

    def parse
      @part = ::Part.new
      load_episodes
      apply_additional_metadata
      part
    end

    def load_episodes
      part.episodes = metadata[:episodes].map do |episode|
        Parser::Episode.new(episode).parse
      end
    end

    def apply_additional_metadata
      part.assign_attributes(simple_attributes)
    end
  end
end
