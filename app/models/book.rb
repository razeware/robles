# frozen_string_literal: true

# The top-level model object
class Book
  include ActiveModel::Model
  include ActiveModel::Serializers::JSON
  include Concerns::ImageAttachable
  include Concerns::MarkdownRenderable

  attr_accessor :sku, :edition, :title, :description, :released_at, :sections, :git_commit_hash,
                :materials_url, :cover_image, :gallery_image, :twitter_card_image,
                :trailer_video_url, :version_description, :professional, :difficulty,
                :platform, :language, :editor, :domains, :categories, :who_is_this_for_md,
                :covered_concepts_md, :root_path, :hide_chapter_numbers, :in_flux,
                :forum_url, :pages, :short_description, :recommended_skus, :contributors
  attr_image :cover_image_url, source: :cover_image
  attr_image :gallery_image_url, source: :gallery_image
  attr_image :twitter_card_image_url, source: :twitter_card_image
  attr_markdown :who_is_this_for, source: :who_is_this_for_md, file: false
  attr_markdown :covered_concepts, source: :covered_concepts_md, file: false

  validates :sku, :edition, :title, presence: true
  validates_inclusion_of :difficulty, in: %w[beginner intermediate advanced]

  def initialize(attributes = {})
    super
    @sections ||= []
    @contributors ||= []
    @hide_chapter_numbers ||= false
    @in_flux ||= false
  end

  # Used for serialisation
  def attributes
    { sku: nil, edition: nil, title: nil, description: nil, released_at: nil, sections: [],
      git_commit_hash: nil, materials_url: nil, cover_image_url: nil, gallery_image_url: nil,
      twitter_card_image_url: nil, trailer_video_url: nil, version_description: nil,
      professional: nil, difficulty: nil, platform: nil, language: nil, editor: nil, domains: [],
      categories: [], who_is_this_for: nil, covered_concepts: nil, hide_chapter_numbers: nil,
      in_flux: nil, forum_url: nil, pages: nil, short_description: nil, recommended_skus: [],
      contributors: [] }.stringify_keys
  end
end
