# frozen_string_literal: true

# The smallest quantity of content
class Text
  include ActiveModel::Model
  include ActiveModel::Serializers::JSON
  include Concerns::AutoNumberable
  include Concerns::ImageAttachable
  include Concerns::MarkdownRenderable
  include Concerns::TitleCleanser

  attr_accessor :title, :ordinal, :ref, :description_md, :authors, :markdown_file, :root_path, :free

  attr_markdown :body, source: :markdown_file, file: true
  attr_markdown :description, source: :description_md, file: false
  validates :title, :ordinal, :ref, :markdown_file, presence: true
  validate do |text|
    # Check the ref is a string
    errors.add(:ref, 'must be a string') unless text.ref.is_a?(String)
  end

  def initialize(attributes = {})
    super
    @authors ||= []
    @free ||= false
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

  def episode_type
    'text'
  end

  def segment_type
    'text'
  end
end
