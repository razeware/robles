# frozen_string_literal: true

# A stand-in for ImageProvider::Provider that serves pre-canned representations
# without touching S3 or ImageMagick. The renderer only ever asks an image
# provider two things, so that is all this implements.
class FakeImageRepresentation
  attr_reader :width, :remote_url

  def initialize(width, remote_url)
    @width = width
    @remote_url = remote_url
  end

  alias variant width

  def width_px
    ImageRepresentation::WIDTHS[width]
  end
end

# Every image gets the full set of variants except the ones named in
# `original_only`, which stand in for GIFs (no generated variants).
class FakeImageProvider
  CDN_ROOT = 'https://images.example.com'

  attr_reader :width_required, :original_only

  def initialize(width_required: true, original_only: ['animation.gif'])
    @width_required = width_required
    @original_only = original_only
  end

  def representations_for_local_url(url)
    basename = Pathname.new(url).basename.to_s
    key = basename.sub(/\.[^.]+\z/, '')
    widths = original_only.include?(basename) ? [:original] : ImageRepresentation::DEFAULT_WIDTHS.keys
    widths.map do |width|
      suffix = width == :original ? 'original' : "w#{ImageRepresentation::WIDTHS[width]}"
      FakeImageRepresentation.new(width, "#{CDN_ROOT}/#{key}/#{suffix}#{Pathname.new(basename).extname}")
    end
  end
end
