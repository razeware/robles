# frozen_string_literal: true

# The smallest quantity of content
class Chapter
  include ActiveModel::Model
  include ActiveModel::Serializers::JSON
  include Concerns::AutoNumberable
  include Concerns::ImageAttachable
  include Concerns::MarkdownRenderable
  include Concerns::TitleCleanser

  attr_accessor :title, :number, :ordinal, :description, :authors, :markdown_file, :root_path, :free
  attr_markdown :body, source: :markdown_file, file: true
  validates :title, :number, :ordinal, :markdown_file, presence: true

  def initialize(attributes = {})
    super
    @authors ||= []
    @free ||= false
  end

  def slug
    "#{number}-#{title.parameterize}"
  end

  # Used for serialisation
  def attributes
    { title: nil, number: nil, ordinal: nil, description: nil, body: nil, authors: [], free: false }.stringify_keys
  end

  # Used for linting
  def validation_name
    title
  end
end
