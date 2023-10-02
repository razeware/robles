# frozen_string_literal: true

# A MMLP module has multiple lesson
class Lesson
  include ActiveModel::Model
  include ActiveModel::Serializers::JSON
  include Concerns::ImageAttachable
  include Concerns::MarkdownRenderable

  attr_accessor :title, :description, :ordinal, :ref, :segments

  validates :title, :ordinal, presence: true

  def initialize(attributes = {})
    super
    @segments ||= []
  end

  # Used for serialisation
  def attributes
    { title: nil, description: nil, ordinal: nil, segments: [], ref: nil }.stringify_keys
  end

  # Used for linting
  def validation_name
    title
  end
end
