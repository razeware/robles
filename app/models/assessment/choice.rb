# frozen_string_literal: true

# A video represents a single quiz question in an assessment
class Assessment::Choice
  include ActiveModel::Model
  include ActiveModel::Serializers::JSON
  include Concerns::MarkdownRenderable

  attr_accessor :ordinal, :ref, :option_md, :correct

  attr_markdown :option, source: :option_md, file: false
  validates :option_md, :ref, presence: true

  # Used for serialisation
  def attributes
    { ordinal: nil, ref: nil, option: nil, correct: nil }.stringify_keys
  end
end
