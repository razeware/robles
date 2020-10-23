# frozen_string_literal: true

# Defines a specific size of an image
class ImageRepresentation
  include ActiveModel::Model
  include ActiveModel::Serializers::JSON
  include ImageProvider::Concerns::Resizable
  include ImageProvider::Concerns::Uploadable

  DEFAULT_WIDTHS = {
    small: 150,
    medium: 300,
    large: 700,
    original: nil
  }.freeze

  OTHER_WIDTHS = {
    w180: 180,
    w300: 300,
    w594: 594,
    w1800: 1800
  }.freeze

  WIDTHS = DEFAULT_WIDTHS.merge(OTHER_WIDTHS).freeze

  attr_accessor :width, :image

  validates :width, inclusion: { in: WIDTHS.keys }, presence: true
  validates :image, presence: true

  delegate :uploaded_image_root_path, to: :image

  def filename
    width_name = original? ? 'original' : "w#{width_px}"
    "#{image.key}/#{width_name}#{image.extension}"
  end

  def key
    "#{uploaded_image_root_path}/#{filename}"
  end

  def width_px
    WIDTHS[width]
  end

  def source_url
    image.local_url
  end

  # Used for serialisation
  alias url remote_url
  alias variant width

  def attributes
    { url: nil, variant: nil }
  end
end
