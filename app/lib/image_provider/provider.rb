# frozen_string_literal: true

module ImageProvider
  # Creates an interface for giving access to images that have been processed and uploaded
  class Provider
    include Util::Logging

    attr_reader :extractor, :width_required

    def initialize(extractor:,width_required:)
      @extractor = extractor
      @width_required = width_required
    end

    def process
      logger.info('Extracting images')
      extractor.extract
      logger.info('Beginning image upload')
      futures = extractor.images.map do |image|
        Concurrent::Promises.future do
          image.upload
        end
      end
      Concurrent::Promises.zip(*futures).wait
      logger.info('Completed image upload')
    end

    def representations_for_local_url(url)
      clean_url = Pathname.new(url).cleanpath.to_s
      extractor.images
               .filter { |image| image.local_url == clean_url }
               .flat_map(&:representations)
    end
  end
end
