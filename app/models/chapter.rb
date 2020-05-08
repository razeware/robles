# frozen_string_literal: true

# The smallest quantity of content
class Chapter
  include ActiveModel::Model
  include ActiveModel::Serializers::JSON

  attr_accessor :title, :number, :ordinal, :description, :body, :authors, :markdown_file, :markdown_source
  validates :title, :number, :ordinal, :markdown_file, presence: true

  # Used for serialisation
  def attributes
    { title: nil, number: nil, ordinal: nil, description: nil, body: nil, authors: [] }.stringify_keys
  end
end
