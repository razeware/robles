# frozen_string_literal: true

# The top-level model object for a video course
class VideoCourse
  include ActiveModel::Model
  include ActiveModel::Serializers::JSON
  include Concerns::ImageAttachable
  include Concerns::MarkdownRenderable

  attr_accessor :shortcode, :version, :version_description, :title, :course_type, :description_md,
                :short_description, :released_at, :materials_url, :professional, :difficulty,
                :platform, :language, :editor, :domains, :categories, :who_is_this_for_md,
                :covered_concepts_md, :authors, :parts, :git_commit_hash
  attr_markdown :who_is_this_for, source: :who_is_this_for_md, file: false
  attr_markdown :covered_concepts, source: :covered_concepts_md, file: false
  attr_markdown :description, source: :description_md, file: false

  validates :shortcode, :version, :title, :version_description, :description_md, :domains,
            :categories, presence: true
  validates_inclusion_of :difficulty, in: %w[beginner intermediate advanced]
  validates_inclusion_of :course_type, in: %w[core spotlight]
  validates_each :domains do |record, attr, value|
    value.each do |domain|
      record.errors.add(attr, "(#{domain}) not included in the list") unless %w[ios android flutter server-side-swift unity macos].include?(domain)
    end
  end

  def initialize(attributes = {})
    super
    @parts ||= []
  end

  # Used for serialisation
  def attributes
    { shortcode: nil, version: nil, version_description: nil, title: nil, course_type: nil,
      description: nil, short_description: nil, released_at: nil, materials_url: nil,
      professional: nil, difficulty: nil, platform: nil, language: nil, editor: nil, domains: [],
      categories: [], who_is_this_for: nil, covered_concepts: nil, authors: [], parts: [],
      git_commit_hash: nil }.stringify_keys
  end

  # Used for linting
  def validation_name
    title
  end
end
