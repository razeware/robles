# frozen_string_literal: true

# A collection of chapters
class Section
  include ActiveModel::Model
  include ActiveModel::Serializers::JSON
  include Concerns::MarkdownRenderable
  include Concerns::TitleCleanser

  attr_accessor :title, :number, :ordinal, :chapters, :markdown_file
  attr_markdown :description, source: :markdown_file, file: true
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
