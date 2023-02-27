# frozen_string_literal: true

module Api
  module Alexandria
    # Allow uploading of books to alexandria
    class BookUploader
      include Util::Logging

      attr_reader :book

      PUBLISH_URL = '/api/editions/publish'

      def self.upload(book)
        new(book).upload
      end

      def initialize(book)
        @book = book
      end

      def upload
        conn.post do |req|
          req.url api_uri
          req.body = payload
        end
      end

      private

      def api_uri
        path = [
          ALEXANDRIA_BASE_URL,
          PUBLISH_URL
        ].join

        URI(path)
      end

      def conn
        @conn ||= Faraday.new(headers: { 'Content-Type' => 'application/json' }) do |faraday|
          faraday.response(:logger, logger) do |logger|
            logger.filter(/(Token token=\\\")(\w+)/, '\1[REMOVED]')
          end
          faraday.response(:raise_error)
          faraday.adapter(Faraday.default_adapter)
          faraday.request(:authorization, 'Bearer', ALEXANDRIA_SERVICE_API_TOKEN)
          faraday.request(:retry)
        end
      end

      def payload
        { book: book }.to_json
      end
    end
  end
end
