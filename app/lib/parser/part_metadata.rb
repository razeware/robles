# frozen_string_literal: true

module Parser
  # Parse a symbolised hash into a Part, with nested Episodes
  class PartMetadata
    include Parser::SimpleAttributes

    VALID_SIMPLE_ATTRIBUTES = %i[title description ordinal].freeze

    attr_accessor :part, :metadata

    def initialize(part, metadata)
      @part = part
      @metadata = metadata
    end

    def apply!
      part.assign_attributes(simple_attributes)
    end
  end
end
