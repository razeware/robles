# frozen_string_literal: true

module Api
  module Alexandria
    # Allow uploading of content_modules to alexandria
    class ContentModuleUploader
      include Util::Logging

      attr_reader :content_module

      PUBLISH_URL = '/api/content_modules/publish'

      def self.upload(content_module)
        new(content_module).upload
      end

      def initialize(content_module)
        @content_module = content_module
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
            logger.filter(/(Token token=\\")(\w+)/, '\1[REMOVED]')
          end
          faraday.response(:raise_error)
          faraday.adapter(Faraday.default_adapter)
          faraday.request(:authorization, 'Bearer', ALEXANDRIA_SERVICE_API_TOKEN)
          faraday.request(:retry)
        end
      end

      def payload
        { content_module: }.to_json
      end
    end
  end
end
