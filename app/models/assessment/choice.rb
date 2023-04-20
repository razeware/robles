# frozen_string_literal: true

# A video represents a single quiz question in an assessment
class Assessment::Choice
  include ActiveModel::Model
  include ActiveModel::Serializers::JSON
  include Concerns::MarkdownRenderable

  attr_accessor :ordinal, :ref, :option_md, :correct

  attr_markdown :option, source: :option_md, file: false
  validates :option_md, :ref, presence: true
  validate do |choice|
    # Check the ref is a string
    errors.add(:ref, 'must be a string') unless choice.ref.is_a?(String)
    # Check that the option_md is a string
    errors.add(:option_md, 'must be a string') unless choice.option_md.is_a?(String)
  end

  # Used for serialisation
  def attributes
    { ordinal: nil, ref: nil, option: nil, correct: nil }.stringify_keys
  end

  # And for validation
  def validation_name
    "#{ref} (#{option_md})".chomp
  end
end
