# frozen_string_literal: true

# An episode represents a single video in a course
class Episode
  include ActiveModel::Model
  include ActiveModel::Serializers::JSON
  include Concerns::MarkdownRenderable

  attr_accessor :title, :ordinal, :free, :description_md, :short_description, :authors_notes_md,
                :authors
  attr_markdown :description, source: :description_md, file: false
  attr_markdown :authors_notes, source: :authors_notes_md, file: false
  validates :title, :ordinal, presence: true

  def initialize(attributes = {})
    super
    @authors ||= []
    @free ||= false
  end

  # Used for serialisation
  def attributes
    { title: nil, ordinal: nil, free: false, description: nil, short_description: nil, authors: [] }.stringify_keys
  end
end
