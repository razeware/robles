# frozen_string_literal: true

# The smallest quantity of content
class Chapter
  include ActiveModel::Model
  include ActiveModel::Serializers::JSON
  include Concerns::AutoNumberable
  include Concerns::ImageAttachable
  include Concerns::MarkdownRenderable
  include Concerns::TitleCleanser
  include AiDisclosure

  attr_accessor :title, :number, :ordinal, :description, :authors, :markdown_file, :root_path, :free, :kind

  # Front matter that robles already gives a kind of its own. Neither says
  # anything about how the book was made.
  AI_DISCLOSURE_EXEMPT_KINDS = %w[dedications team-bios].freeze

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
    { title: nil, number: nil, ordinal: nil, description: nil, body: nil, authors: [], free: false }
      .stringify_keys
      .merge(ai_disclosure_defaults)
  end

  # Used for linting
  def validation_name
    title
  end

  # Other front matter is an ordinary chapter, and opts out with
  # `ai_disclosure: not_applicable`
  def ai_disclosure_not_applicable_permitted?
    true
  end

  def ai_disclosure_expected?
    AI_DISCLOSURE_EXEMPT_KINDS.exclude?(kind)
  end

  # For wrapping content
  def wrapper_class
    {
      chapter: nil,
      dedications: 'c-book-chapter__dedications',
      'team-bios': 'c-book-chapter__team'
    }[kind&.to_sym]
  end
end
