# frozen_string_literal: true

# An image extracted from the markdown
class Image
  include ActiveModel::Model
  include ImageProvider::BookPathable

  attr_accessor :local_url, :representations

  def self.with_representations(attributes = {})
    new(attributes).tap do |image|
      image.representations = ImageRepresentation::WIDTHS.keys.map do |width|
        ImageRepresentation.new(width: width, image: image)
      end
    end
  end

  def initialize(attributes = {})
    super
    @representations ||= []
  end

  def key
    @key ||= Digest::SHA256.file(local_url).hexdigest
  end

  def extension
    @extension ||= Pathname.new(local_url).extname
  end

  def remote_urls
    representations.map(&:remote_url)
  end

  def upload
    p local_url
    representations.each do |representation|
      next if representation.uploaded?

      p "...generating #{representation.width}"
      representation.generate
      p "...uploading #{representation.width}"
      representation.upload
    end
  end
end
