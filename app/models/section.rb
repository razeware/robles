# frozen_string_literal: true

# A collection of chapters
class Section
  include ActiveModel::Model
  include ActiveModel::Serializers::JSON

  attr_accessor :title, :number, :description, :chapters
  validates :title, :number, presence: true

  # Used for serialisaion
  def attributes
    { title: nil, number: nil, description: nil, chapters: [] }.stringify_keys
  end
end
