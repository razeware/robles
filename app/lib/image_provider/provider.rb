# frozen_string_literal: true

require 'timeout'

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
      logger.info("Beginning upload of #{extractor.images.count} image(s), up to #{upload_concurrency} at a time")
      pool = Concurrent::FixedThreadPool.new(upload_concurrency)
      Concurrent::Promises.zip(*upload_futures(pool)).wait
      pool.shutdown
      pool.wait_for_termination
      logger.info('Completed image upload')
    end

    # Resizing images (notably animated GIFs) shells out to ImageMagick, which
    # is CPU- and memory-hungry. Running every image at once on a small CI
    # runner exhausts resources and can grind the whole step to a halt, so we
    # cap how many upload/resize jobs run concurrently.
    def upload_concurrency
      @upload_concurrency ||= [ENV.fetch('ROBLES_IMAGE_UPLOAD_CONCURRENCY', Concurrent.processor_count).to_i, 1].max
    end

    # Wall-clock budget per image. The ImageMagick limits make a runaway resize
    # abort by itself, but this is the final backstop that guarantees one stuck
    # image can never hang the whole circulate job.
    def image_upload_timeout
      @image_upload_timeout ||= [ENV.fetch('ROBLES_IMAGE_UPLOAD_TIMEOUT', 300).to_i, 1].max
    end

    def upload_futures(pool)
      extractor.images.map do |image|
        Concurrent::Promises.future_on(pool) do
          Timeout.timeout(image_upload_timeout) { image.upload }
        rescue Timeout::Error
          # Surface (don't swallow) a stuck image: Concurrent::Promises#wait
          # hides rejected futures, so log before re-raising.
          logger.error("Timed out after #{image_upload_timeout}s uploading image #{image_descriptor(image)}")
          raise
        rescue StandardError => e
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
