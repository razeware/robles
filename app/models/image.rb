# frozen_string_literal: true

# An image extracted from the markdown
class Image
  include ActiveModel::Model

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
end
