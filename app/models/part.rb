# frozen_string_literal: true

# A video course has multiple parts
class Part
  include ActiveModel::Model
  include ActiveModel::Serializers::JSON
  include Concerns::ImageAttachable
  include Concerns::MarkdownRenderable

  attr_accessor :title, :description, :ordinal, :episodes

  validates :title, :ordinal, presence: true

  def initialize(attributes = {})
    super
    @episodes ||= []
  end

  # Used for serialisation
  def attributes
    { title: nil, description: nil, ordinal: nil, episodes: [] }.stringify_keys
  end

  # Used for linting
  def validation_name
    title
  end
end
