# frozen_string_literal: true

# The smallest quantity of content
class Chapter
  include ActiveModel::Model
  include ActiveModel::Serializers::JSON
  include Concerns::AutoNumberable
  include Concerns::ImageAttachable
  include Concerns::MarkdownRenderable
  include Concerns::TitleCleanser

  attr_accessor :title, :number, :ordinal, :description, :authors, :markdown_file, :root_path, :free, :kind

  attr_markdown :body, source: :markdown_file, file: true, wrapper_class: :wrapper_class
  validates :title, :number, :ordinal, :markdown_file, presence: true

  def initialize(attributes = {})
    super
    @authors ||= []
    @free ||= false
    @kind ||= 'chapter'
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

  # For wrapping content
  def wrapper_class
    {
      'chapter': nil,
      'dedications': 'c-book-chapter__dedications',
      'team-bios': 'c-book-chapter__team'
    }[kind&.to_sym]
  end
end
