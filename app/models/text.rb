# frozen_string_literal: true

# The smallest quantity of content
class Text
  include ActiveModel::Model
  include ActiveModel::Serializers::JSON
  include Concerns::AutoNumberable
  include Concerns::ImageAttachable
  include Concerns::MarkdownRenderable
  include Concerns::TitleCleanser

  attr_accessor :title, :ordinal, :ref, :description, :authors, :markdown_file, :root_path, :free, :kind

  attr_markdown :body, source: :markdown_file, file: true, wrapper_class: :wrapper_class
  validates :title, :ordinal, :markdown_file, presence: true

  def initialize(attributes = {})
    super
    @authors ||= []
    @free ||= false
    @kind ||= 'chapter'
  end

  def slug
    "#{ref}-#{title.parameterize}"
  end

  # Used for serialisation
  def attributes
    { title: nil, ordinal: nil, description: nil, body: nil, authors: [], free: false, ref: nil, episode_type:, segment_type: }.stringify_keys
  end

  # Used for linting
  def validation_name
    title
  end

  # For wrapping content
  def wrapper_class
    {
      chapter: nil,
      dedications: 'c-book-chapter__dedications',
      'team-bios': 'c-book-chapter__team'
    }[kind&.to_sym]
  end

  def episode_type
    'text'
  end

  def segment_type
    'text'
  end
end
