# frozen_string_literal: true

module ImageProvider
  # Creates an interface for giving access to images that have been processed and uploaded
  class Provider
    attr_reader :book

    def initialize(book:)
      @book = book
    end

    def process
      extractor.extract
      extractor.images.each(&:upload)
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
