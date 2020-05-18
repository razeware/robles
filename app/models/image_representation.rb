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

  attr_accessor :width, :local_url, :root_path, :uploaded, :image

  validates :width, inclusion: { in: WIDTHS.keys }, presence: true
  validates :image, presence: true
  validates :root_path, presence: true

  def filename
    "#{image.key}/#{width_px}w#{image.extension}"
  end

  def key
    raise 'Invalid representation' unless valid?

    "#{root_path}/#{filename}"
  end

  def width_px
    WIDTHS[width]
  end

  def remote_url
    return unless uploaded && IMAGES_CDN_HOST.present?

    "https://#{IMAGES_CDN_HOST}/#{key}"
  end
end
