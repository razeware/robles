# frozen_string_literal: true

# A collection of chapters
class Section
  include ActiveModel::Model
  include ActiveModel::Serializers::JSON
  include ::MarkdownRenderable
  include ::TitleCleanser

  attr_accessor :title, :number, :ordinal, :description, :chapters, :markdown_file
  attr_markdown :description
  validates :title, :number, :ordinal, presence: true

  def initialize(attributes = {})
    super
    @chapters ||= []
  end

  # Used for serialisaion
  def attributes
    { title: nil, number: nil, ordinal: nil, description: nil, chapters: [] }.stringify_keys
  end
end
