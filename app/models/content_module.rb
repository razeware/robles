# frozen_string_literal: true

# The top-level model object for a MMLP module
class ContentModule
  include ActiveModel::Model
  include ActiveModel::Serializers::JSON
  include Concerns::ImageAttachable
  include Concerns::MarkdownRenderable

  attr_accessor :shortcode, :version, :version_description, :title, :description_md,
                :short_description, :released_at, :materials_url, :professional, :difficulty,
                :platform, :language, :editor, :domains, :categories, :who_is_this_for_md, :module_outcomes_md,
                :covered_concepts_md, :authors, :lessons, :git_commit_hash,
                :featured_banner_image, :twitter_card_image, :root_path, :access_personal,
                :access_team, :module_type

  attr_markdown :who_is_this_for, source: :who_is_this_for_md, file: false
  attr_markdown :covered_concepts, source: :covered_concepts_md, file: false
  attr_markdown :outcomes, source: :module_outcomes_md, file: false
  attr_markdown :description, source: :description_md, file: false
  attr_image :featured_banner_image_url, source: :featured_banner_image, variants: %i[original w750 w225 w90]
  attr_image :twitter_card_image_url, source: :twitter_card_image, variants: %i[original w1800]

  validates :shortcode, :version, :title, :version_description, :description_md, presence: true
  validates_presence_of :domains, :categories, unless: -> { module_type == 'info' }
  validates_inclusion_of :difficulty, in: %w[beginner intermediate advanced]
  validates_inclusion_of :professional, :access_personal, :access_team, in: [true, false]
  validates_inclusion_of :module_type, in: %w[study info]
  validates :lessons, length: { minimum: 1 }, allow_blank: false, lessons: true
  validates_each :domains do |record, attr, value|
    value.each do |domain|
      record.errors.add(attr, "(#{domain}) not included in the list") unless %w[ios android flutter server-side-swift unity macos professional-growth ai].include?(domain)
    end
  end

  def initialize(attributes = {})
    super
    @lessons ||= []
    @module_type ||= 'study'
  end

  # Used for serialisation
  def attributes
    { shortcode: nil, version: nil, version_description: nil, title: nil,
      description: nil, short_description: nil, released_at: nil, materials_url: nil,
      professional: nil, difficulty: nil, platform: nil, language: nil, editor: nil, domains: [],
      categories: [], who_is_this_for: nil, covered_concepts: nil, outcomes: nil, authors: [], lessons: [],
      git_commit_hash: nil, featured_banner_image_url: [],
      twitter_card_image_url: [], access_personal: nil, access_team: nil, module_type: nil }.stringify_keys
  end

  # Used for linting
  def validation_name
    title
  end
end
