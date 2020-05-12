# frozen_string_literal: true

# The top-level model object
class Book
  include ActiveModel::Model
  include ActiveModel::Serializers::JSON

  attr_accessor :sku, :edition, :title, :description, :release_date, :sections
  validates :sku, :edition, :title, presence: true

  # Used for serialisation
  def attributes
    { sku: nil, edition: nil, title: nil, description: nil, release_date: nil, sections: [] }.stringify_keys
  end
end
