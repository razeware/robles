# frozen_string_literal: true

# A MMLP module has multiple lesson
class Lesson
  include ActiveModel::Model
  include ActiveModel::Serializers::JSON
  include Concerns::ImageAttachable
  include Concerns::MarkdownRenderable

  attr_accessor :title, :description_md, :ordinal, :ref, :segments, :learning_objectives_md, :free, :program_shortcode

  attr_markdown :description, source: :description_md, file: false
  attr_markdown :learning_objectives, source: :learning_objectives_md, file: false
  validates :title, :ordinal, :ref, presence: true
  validates :segments, length: { minimum: 1 }, allow_blank: false, segments: true

  def initialize(attributes = {})
    super
    @free ||= false
    @segments ||= []
  end

  def slug
    "#{ref}-#{title.parameterize}"
  end

  # Used for serialisation
  def attributes
    { title: nil, description: nil, learning_objectives: nil, ordinal: nil, segments: [], ref: nil, free: false, program_shortcode: nil }.stringify_keys
  end

  # Used for linting
  def validation_name
    title
  end
end
