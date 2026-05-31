# frozen_string_literal: true

module ImageProvider
  # Creates an interface for giving access to images that have been processed and uploaded
  class Provider
    include Util::Logging

    attr_reader :extractor, :width_required

    def initialize(extractor:, width_required: true)
      @extractor = extractor
      @width_required = width_required
    end

    def process
      logger.info('Extracting images')
      extractor.extract
      logger.info("Beginning upload of #{extractor.images.count} image(s)")
      Concurrent::Promises.zip(*upload_futures).wait
      logger.info('Completed image upload')
    end

    def upload_futures
      extractor.images.map do |image|
        Concurrent::Promises.future do
          image.upload
        rescue StandardError => e
          # Surface the failure: Concurrent::Promises#wait swallows rejected
          # futures, so without this an image upload error (or hang) would
          # otherwise vanish from the logs.
          logger.error("Failed to upload image #{image_descriptor(image)}: #{e.class} #{e.message}")
          raise
        end
      end
    end

    def image_descriptor(image)
      image.try(:key).presence || image.try(:local_url).presence || image.class.name
    end

    def representations_for_local_url(url)
      clean_url = Pathname.new(url).cleanpath.to_s
      extractor.images
               .filter { |image| image.local_url == clean_url }
               .flat_map(&:representations)
    end
  end
end
