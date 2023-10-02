# frozen_string_literal: true

# An Assessment is a superclass that represents a single assessment in a course
class Assessment
  include ActiveModel::Model
  include ActiveModel::Serializers::JSON
  include Concerns::MarkdownRenderable

  attr_accessor :title, :ordinal, :description_md, :short_description, :assessment_file, :root_path,
                :assessment_type, :ref

  attr_markdown :description, source: :description_md, file: false
  validates :title, :ordinal, :description_md, :ref, presence: true
  validate do |assessment|
    # Check the ref is a string
    errors.add(:ref, 'must be a string') unless assessment.ref.is_a?(String)
  end

  # Rather than making a factory, we'll just use this method to create the correct
  # subclass of Assessment
  def self.create(attributes = {})
    case attributes[:assessment_type]
    when 'quiz'
      Assessment::Quiz.new(attributes)
    else
      raise "Unknown assessment type: #{attributes[:assessment_type]}"
    end
  end

  def slug
    "#{ref}-#{title.parameterize}"
  end

  def episode_type
    'assessment'
  end

  def segment_type
    'assessment'
  end

  # Used for serialisation
  def attributes
    { title: nil, ordinal: nil, description: nil, short_description: nil, ref: nil, episode_type:, segment_type:, assessment_type: nil }.stringify_keys
  end

  # Used for linting
  def validation_name
    "#{ref} #{title}".chomp
  end
end
