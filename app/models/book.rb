# frozen_string_literal: true

# The top-level model object
class Book
  include ActiveModel::Model
  include ActiveModel::Serializers::JSON

  attr_accessor :sku, :edition, :title, :description, :released_at, :sections
  validates :sku, :edition, :title, presence: true

  def initialize(attributes = {})
    super
    @sections ||= []
  end

  # Used for serialisation
  def attributes
    { sku: nil, edition: nil, title: nil, description: nil, released_at: nil, sections: [] }.stringify_keys
  end
end
