# frozen_string_literal: true

# Defines a specific size of an image
class ImageRepresentation
  include ActiveModel::Model
  include ImageProvider::Uploadable

  WIDTHS = {
    small: 150,
    medium: 300,
    large: 700,
    original: nil
  }.freeze

  attr_accessor :width, :local_url, :image

  validates :width, inclusion: { in: WIDTHS.keys }, presence: true
  validates :image, presence: true

  delegate :uploaded_image_root_path, to: :image

  def filename
    "#{image.key}/w#{width_px}#{image.extension}"
  end

  def key
    "#{uploaded_image_root_path}/#{filename}"
  end

  def width_px
    WIDTHS[width]
  end
end
