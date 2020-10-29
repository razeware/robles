# frozen_string_literal: true

# User and role for a chapter
class Author
  include ActiveModel::Model
  include ActiveModel::Serializers::JSON

  attr_accessor :username, :role
  validates :username, :role, presence: true

  # Used for serialisation
  def attributes
    { username: nil, role: nil }.stringify_keys
  end

  # Used for linting
  def validation_name
    username
  end
end
