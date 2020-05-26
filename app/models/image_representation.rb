# frozen_string_literal: true

# Defines a specific size of an image
class ImageRepresentation
  include ActiveModel::Model
  include ImageProvider::Concerns::Resizable
  include ImageProvider::Concerns::Uploadable

  WIDTHS = {
    small: 150,
    medium: 300,
    large: 700,
    original: nil
  }.freeze

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
end
