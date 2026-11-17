# frozen_string_literal: true

module Api
  module Alexandria
    # Allow uploading of books to alexandria, through API v2
    class BookUploader
      attr_reader :book

      V2_PUBLISH_PATH = '/api/v2/editions/publish'

      def self.upload(book)
        new(book).upload
      end

      # In a real run `token` is always ALEXANDRIA_SERVICE_API_TOKEN. The
      # keywords let the tests supply a token and a client.
      def initialize(book, token: ALEXANDRIA_SERVICE_API_TOKEN, client: nil)
        @book = book
        @token = token
        @client = client
      end

      # Refuses any token but robles's kst_ token before a request is made
      # (WEB-8371). The body is the one v1 took (WEB-8205).
      def upload
        Api::V2Client.require_service_token!(@token, name: 'ALEXANDRIA_SERVICE_API_TOKEN', service: 'alexandria')
        client.post(V2_PUBLISH_PATH, payload)
      end

      private

      # Built lazily, after the token check
      def client
        @client ||= Api::V2Client.new(base_url: ALEXANDRIA_BASE_URL, token: @token)
      end

      def payload
        { book: }.to_json
      end
    end
  end
end
