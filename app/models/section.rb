# frozen_string_literal: true

# A collection of chapters
class Section
  include ActiveModel::Model
  include ActiveModel::Serializers::JSON

  attr_accessor :title, :number, :description, :chapters, :markdown_file, :markdown_source, :body
  validates :title, :number, presence: true

  # Used for serialisaion
  def attributes
    { title: nil, number: nil, description: nil, body: nil, chapters: [] }.stringify_keys
  end
end
