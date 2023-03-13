# frozen_string_literal: true

# A video represents a single quiz question in an assessment
class Assessment::Question
  include ActiveModel::Model
  include ActiveModel::Serializers::JSON
  include Concerns::MarkdownRenderable

  attr_accessor :ordinal, :question_md, :explanation_md, :choices

  attr_markdown :question, source: :question_md, file: false
  attr_markdown :explanation, source: :explanation_md, file: false
  validates :question_md, :explanation_md, presence: true

  def initialize(attributes = {})
    super
    @choices ||= []
  end

  # Used for serialisation
  def attributes
    { question: nil, explanation: nil, choices: [], ordinal: nil }.stringify_keys
  end
end
