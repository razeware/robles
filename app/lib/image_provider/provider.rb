# frozen_string_literal: true

module ImageProvider
  # Creates an interface for giving access to images that have been processed and uploaded
  class Provider
    include Util::Logging

    attr_reader :book

    def initialize(book:)
      @book = book
    end

    def process
      logger.info('Extracting images from book')
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

    def remote_urls_for_local(url)
      extractor.images
               .find { |image| image.local_url == url }
               .remote_urls
    end

    def extractor
      @extractor ||= Extractor.new(book)
    end
  end
end
