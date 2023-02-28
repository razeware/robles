# frozen_string_literal: true

# An Assessment is a superclass that represents a single assessment in a course
class Assessment
  include ActiveModel::Model
  include ActiveModel::Serializers::JSON
  include Concerns::MarkdownRenderable

  attr_accessor :title, :ordinal, :description_md, :short_description, :assessment_file, :root_path,
                :assessment, :ref

  attr_markdown :description, source: :description_md, file: false
  validates :title, :ordinal, :description_md, :short_description, presence: true

  # Rather than making a factory, we'll just use this method to create the correct
  # subclass of Assessment
  def self.create(attributes = {})
    case attributes[:assessment]
    when 'quiz'
      Assessment::Quiz.new(attributes)
    else
      raise "Unknown assessment type: #{attributes[:assessment]}"
    end
  end

  def slug
    "#{ordinal.to_s.rjust(2, '0')}-#{title.parameterize}"
  end

  # Used for serialisation
  def attributes
    { title: nil, ordinal: nil, description: nil, short_description: nil }.stringify_keys
  end

  # Used for linting
  def validation_name
    title
  end
end
