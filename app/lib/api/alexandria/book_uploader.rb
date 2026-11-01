# frozen_string_literal: true

module Api
  module Alexandria
    # Allow uploading of books to alexandria
    class BookUploader
      include Util::Logging

      attr_reader :book

      PUBLISH_URL = '/api/editions/publish'
      V2_PUBLISH_PATH = '/api/v2/editions/publish'

      def self.upload(book)
        new(book).upload
      end

      # In a real run `token` is always ALEXANDRIA_SERVICE_API_TOKEN. The
      # keywords let the tests choose a path.
      def initialize(book, token: ALEXANDRIA_SERVICE_API_TOKEN, client: nil)
        @book = book
        @token = token
        @client = client
      end

      def upload
        return upload_with_api_v2 if Api::V2Client.service_token?(@token)

        conn.post do |req|
          req.url api_uri
          req.body = payload
        end
      end

      private

      # Sends v1's payload, so both paths send the same bytes (WEB-8205)
      def upload_with_api_v2
        client.post(V2_PUBLISH_PATH, payload)
      end

      # Built lazily, so the v1 path never builds it
      def client
        @client ||= Api::V2Client.new(base_url: ALEXANDRIA_BASE_URL, token: @token)
      end

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
            logger.filter(/(Token token=\\")(\w+)/, '\1[REMOVED]')
          end
          faraday.response(:raise_error)
          faraday.adapter(Faraday.default_adapter)
          faraday.request(:authorization, 'Bearer', ALEXANDRIA_SERVICE_API_TOKEN)
          faraday.request(:retry)
        end
      end

      def payload
        { book: }.to_json
      end
    end
  end
end
