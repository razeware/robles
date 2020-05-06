# frozen_string_literal: true

# The smallest quantity of content
class Chapter
  include ActiveModel::Model
  include ActiveModel::Serializers::JSON

  attr_accessor :title, :number, :description, :body, :authors
  validates :title, :number, presence: true

  # Used for serialisation
  def attributes
    { title: nil, number: nil, description: nil, body: nil, authors: [] }.stringify_keys
  end
end
