# frozen_string_literal: true

module Api
  module Alexandria
    # Allow uploading of content_modules to alexandria, through API v2
    class ContentModuleUploader
      include Util::Logging

      attr_reader :content_module

      V2_PUBLISH_PATH = '/api/v2/content_modules/publish'

      def self.upload(content_module)
        new(content_module).upload
      end

      # In a real run `token` is always ALEXANDRIA_SERVICE_API_TOKEN. The
      # keywords let the tests supply a token and a client.
      def initialize(content_module, token: ALEXANDRIA_SERVICE_API_TOKEN, client: nil)
        @content_module = content_module
        @token = token
        @client = client
      end

      # Refuses any token but robles's kst_ token before a request is made
      # (WEB-8371). The body is the one v1 took (WEB-8205), and the client
      # logs the status and the time.
      def upload
        Api::V2Client.require_service_token!(@token, name: 'ALEXANDRIA_SERVICE_API_TOKEN', service: 'alexandria')
        logger.info("Publishing content module '#{content_module.shortcode}' to Alexandria API v2 (#{payload.bytesize} bytes)")
        client.post(V2_PUBLISH_PATH, payload)
      end

      private

      # Built lazily, after the token check
      def client
        @client ||= Api::V2Client.new(base_url: ALEXANDRIA_BASE_URL, token: @token)
      end

      def payload
        @payload ||= { content_module: }.to_json
      end
    end
  end
end
