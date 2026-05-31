# frozen_string_literal: true

# An image extracted from the markdown
class Image
  include ActiveModel::Model
  include Util::Logging

  attr_accessor :local_url, :representations, :uploaded_image_root_path

  def self.with_representations(attributes = {}, variants: nil, representation_attributes: {})
    variants ||= ImageRepresentation::DEFAULT_WIDTHS.keys
    new(attributes).tap do |image|
      image.representations = variants.map do |width|
        ImageRepresentation.new(representation_attributes.merge(width:, image:))
      end
    end
  end

  def self.with_original_representation(attributes = {})
    new(attributes).tap do |image|
      image.representations = [
        ImageRepresentation.new(width: :original, image:, local_server: true)
      ]
    end
  end

  def initialize(attributes = {})
    super
    @representations ||= []
  end

  def key
    @key ||= Digest::MD5.file(local_url).hexdigest
  end

  def extension
    @extension ||= Pathname.new(local_url).extname
  end

  def source_filename
    @source_filename ||= Pathname.new(local_url).basename('.*')
  end

  def remote_urls
    representations.map(&:remote_url)
  end

  def upload
    representations.each do |representation|
      if representation.uploaded?
        logger.info "Skipping #{representation.width} variant for #{local_url} (already uploaded)"
        next
      end
      generate_variant(representation)
      upload_variant(representation)
    end
  end

  # Used for linting
  def validation_name
    local_url
  end

  private

  def generate_variant(representation)
    logger.info "Generating #{representation.width} variant for #{local_url} (source #{source_size})"
    started = monotonic_now
    representation.generate
    logger.info "Generated #{representation.width} variant for #{local_url} in #{elapsed_since(started)}s"
  end

  def upload_variant(representation)
    logger.info "Uploading #{representation.width} variant for #{local_url}"
    started = monotonic_now
    representation.upload
    logger.info "Uploaded #{representation.width} variant for #{local_url} in #{elapsed_since(started)}s"
  end

  def source_size
    "#{(File.size(local_url) / 1024.0 / 1024.0).round(1)}MB"
  rescue SystemCallError
    'unknown size'
  end

  def monotonic_now
    Process.clock_gettime(Process::CLOCK_MONOTONIC)
  end

  def elapsed_since(started)
    (monotonic_now - started).round(1)
  end
end
