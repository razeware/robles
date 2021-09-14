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
    w90: 90,
    w180: 180,
    w225: 225,
    w240: 240,
    w300: 300,
    w560: 560,
    w594: 594,
    w750: 750,
    w1800: 1800
  }.freeze

  WIDTHS = DEFAULT_WIDTHS.merge(OTHER_WIDTHS).freeze

  attr_accessor :width, :image, :include_source_filename

  validates :width, inclusion: { in: WIDTHS.keys }, presence: true
  validates :image, presence: true

  delegate :uploaded_image_root_path, to: :image

  def filename
    basename = original? ? 'original' : "w#{width_px}"
    basename = "#{image.source_filename}_#{basename}" if include_source_filename
    "#{image.key}/#{basename}#{image.extension}"
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
