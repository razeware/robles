# frozen_string_literal: true

# Defines a specific size of an image
class ImageRepresentation
  include ActiveModel::Model

  WIDTHS = {
    small: 150,
    medium: 300,
    large: 700,
    original: nil
  }.freeze

  attr_accessor :width, :remote_url, :local_url, :image

  validates :width, inclusion: { in: WIDTHS.keys }, presence: true
  validates :image, presence: true

  def filename
    "#{image.key}/#{width_px}w#{image.extension}"
  end

  def width_px
    WIDTHS[width]
  end
end
