# frozen_string_literal: true

module Parser
  # Parse a symbolised hash into an Assessment
  class AssessmentMetadata
    include Parser::SimpleAttributes

    VALID_SIMPLE_ATTRIBUTES = %i[title description_md assessment_file assessment_type].freeze

    attr_accessor :assessment, :metadata, :path

    def initialize(assessment, metadata)
      @assessment = assessment
      @metadata = metadata
      @path = assessment.assessment_file
    end

    def apply!
      assessment.assign_attributes(simple_attributes)
      assessment.questions = metadata[:questions].map.with_index do |question, idx|
        parse_question(question, idx)
      end
    end

    private

    def parse_question(question_meta, idx)
      Assessment::Question.new(ordinal: idx + 1).tap do |q|
        q.assign_attributes(question_meta)
        q.choices = question_meta[:choices].map.with_index do |choice_meta, choice_index|
          Assessment::Choice.new(ordinal: choice_index + 1, correct: false).tap do |c|
            c.assign_attributes(choice_meta)
          end
        end
      end
    end
  end
end
