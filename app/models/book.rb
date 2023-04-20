# frozen_string_literal: true

# The top-level model object
class Book
  include ActiveModel::Model
  include ActiveModel::Serializers::JSON
  include Concerns::ImageAttachable
  include Concerns::MarkdownRenderable

  attr_accessor :sku, :edition, :title, :description_md, :released_at, :sections, :git_commit_hash,
                :materials_url, :cover_image, :email_mockup_image, :twitter_card_image, :artwork_image,
                :icon_image, :trailer_video_url, :version_description, :professional, :difficulty,
                :platform, :language, :editor, :domains, :categories, :who_is_this_for_md,
                :covered_concepts_md, :root_path, :hide_chapter_numbers, :in_flux, :deprecated,
                :forum_url, :pages, :short_description, :recommended_skus, :contributors,
                :price_band, :isbn, :amazon_url, :access_personal, :access_team

  attr_image :cover_image_url, source: :cover_image, variants: %i[original w594 w300]
  attr_image :email_mockup_image_url, source: :email_mockup_image, variants: %i[original w180 w300 w594]
  attr_image :twitter_card_image_url, source: :twitter_card_image, variants: %i[original w1800]
  attr_image :artwork_image_url, source: :artwork_image, variants: %i[original w180]
  attr_image :icon_image_url, source: :icon_image, variants: %i[original w180]
  attr_markdown :who_is_this_for, source: :who_is_this_for_md, file: false
  attr_markdown :covered_concepts, source: :covered_concepts_md, file: false
  attr_markdown :description, source: :description_md, file: false

  validates :sku, :edition, :title, presence: true
  validates_inclusion_of :difficulty, in: %w[beginner intermediate advanced]
  validates_inclusion_of :professional, :access_personal, :access_team, in: [true, false]

  def initialize(attributes = {})
    super
    @sections ||= []
    @contributors ||= []
    @hide_chapter_numbers ||= false
    @in_flux ||= false
    @deprecated ||= false
  end

  # Used for serialisation
  def attributes
    { sku: nil, edition: nil, title: nil, description: nil, released_at: nil, sections: [],
      git_commit_hash: nil, materials_url: nil, cover_image_url: [], email_mockup_image_url: [],
      twitter_card_image_url: [], artwork_image_url: [], icon_image_url: [],
      trailer_video_url: nil, version_description: nil, professional: nil, difficulty: nil,
      platform: nil, language: nil, editor: nil, domains: [], categories: [], who_is_this_for: nil,
      covered_concepts: nil, hide_chapter_numbers: nil, in_flux: nil, forum_url: nil, pages: nil,
      short_description: nil, recommended_skus: [], contributors: [], price_band: nil, isbn: nil,
      amazon_url: nil, deprecated: nil, access_personal: nil, access_team: nil }.stringify_keys
  end

  # Used for linting
  def validation_name
    title
  end
end
