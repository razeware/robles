# frozen_string_literal: true

# A video represents a single video in a course
class Video
  include ActiveModel::Model
  include ActiveModel::Serializers::JSON
  include Concerns::ImageAttachable
  include Concerns::MarkdownRenderable

  attr_accessor :title, :ordinal, :free, :description_md, :short_description, :authors_notes_md,
                :authors, :script_file, :root_path, :captions_file, :ref

  attr_markdown :description, source: :description_md, file: false
  attr_markdown :authors_notes, source: :authors_notes_md, file: false
  attr_markdown :transcript, source: :script_file, file: true, vtt_attr: :captions_file
  validates :title, :ordinal, :description_md, :short_description, presence: true

  def initialize(attributes = {})
    super
    @authors ||= []
    @free ||= false
    @ref ||= ordinal
  end

  def slug
    "#{ordinal.to_s.rjust(2, '0')}-#{title.parameterize}"
  end

  def episode_type
    'video'
  end

  # Used for serialisation
  def attributes
    { title: nil, ordinal: nil, free: false, description: nil, short_description: nil, authors_notes: nil,
      authors: [], transcript: nil, ref: nil, episode_type: }.stringify_keys
  end

  # Used for linting
  def validation_name
    title
  end
end
