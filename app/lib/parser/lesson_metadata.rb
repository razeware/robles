# frozen_string_literal: true

module Parser
  # Parse a symbolised hash into a Part, with nested Episodes
  class LessonMetadata
    include Parser::SimpleAttributes

    VALID_SIMPLE_ATTRIBUTES = %i[title description ordinal].freeze

    attr_accessor :lesson, :metadata

    def initialize(lesson, metadata)
      @lesson = lesson
      @metadata = metadata
    end

    def apply!
      lesson.assign_attributes(simple_attributes)
    end
  end
end
