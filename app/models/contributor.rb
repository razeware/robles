# frozen_string_literal: true

# For commissions purposes. Username and proportion
class Contributor
  include ActiveModel::Model
  include ActiveModel::Serializers::JSON

  attr_accessor :username, :percentage
  validates :username, :percentage, presence: true

  def proportion
    BigDecimal(percentage, 8) / 100
  end

  # Used for serialisation
  def attributes
    { username: nil, proportion: nil }.stringify_keys
  end

  # Used for linting
  def validation_name
    username
  end
end
