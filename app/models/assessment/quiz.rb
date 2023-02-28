# frozen_string_literal: true

# A Quiz represents a single quiz-like assessment in a course
class Assessment::Quiz < Assessment
  attr_accessor :questions

  def initialize(attributes = {})
    p attributes
    super
    @questions ||= []
  end

  # Used for serialisation
  def attributes
    super.merge({ questions: [] }.stringify_keys)
  end
end
