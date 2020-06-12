# frozen_string_literal: true

# The top-level model object
class Book
  include ActiveModel::Model
  include ActiveModel::Serializers::JSON
  include Concerns::ImageAttachable
  include Concerns::MarkdownRenderable

  attr_accessor :sku, :edition, :title, :description, :released_at, :sections, :git_commit_hash,
                :materials_url, :cover_image, :version_description, :professional, :difficulty,
                :platform, :language, :editor, :who_is_this_for_md, :covered_concepts_md, :root_path
  attr_image :cover_image_url, source: :cover_image
  attr_markdown :who_is_this_for, source: :who_is_this_for_md, file: false
  attr_markdown :covered_concepts, source: :covered_concepts_md, file: false

  validates :sku, :edition, :title, presence: true
  validates_inclusion_of :difficulty, in: %w[beginner intermediate advanced]

  def initialize(attributes = {})
    super
    @sections ||= []
  end

  # Used for serialisation
  def attributes
    { sku: nil, edition: nil, title: nil, description: nil, released_at: nil, sections: [],
      git_commit_hash: nil, materials_url: nil, cover_image_url: nil, version_description: nil,
      professional: nil, difficulty: nil, platform: nil, language: nil, editor: nil,
      who_is_this_for: nil, covered_concepts: nil }.stringify_keys
  end
end
