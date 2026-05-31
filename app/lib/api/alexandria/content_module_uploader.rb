# frozen_string_literal: true

module Api
  module Alexandria
    # Allow uploading of content_modules to alexandria
    class ContentModuleUploader
      include Util::Logging

      attr_reader :content_module

      PUBLISH_URL = '/api/content_modules/publish'

      # Seconds to wait when establishing the connection to Alexandria.
      OPEN_TIMEOUT = 10
      # Seconds to wait for Alexandria to accept the publish. Generous, because
      # publishing a whole module can be slow, but bounded so a hung Alexandria
      # fails (and is logged) instead of hanging CI indefinitely.
      READ_TIMEOUT = 120

      def self.upload(content_module)
        new(content_module).upload
      end

      def initialize(content_module)
        @content_module = content_module
      end

      def upload
        started_at = monotonic_now
        log_upload_start
        response = conn.post do |req|
          req.url api_uri
          req.body = payload
        end
        log_upload_success(response, started_at)
        response
      rescue Faraday::Error => e
        log_upload_failure(e, started_at)
        raise
      end

      private

      def log_upload_start
        logger.info("Publishing content module '#{content_module.shortcode}' to Alexandria at #{api_uri} (#{payload.bytesize} bytes)")
      end

      def log_upload_success(response, started_at)
        logger.info("Alexandria accepted content module '#{content_module.shortcode}' (HTTP #{response.status}) in #{elapsed_since(started_at)}s")
      end

      def log_upload_failure(error, started_at)
        logger.error("Alexandria publish failed for content module '#{content_module.shortcode}' after #{elapsed_since(started_at)}s: #{error.class} (HTTP #{error.response_status || 'none'})")
        logger.error("Alexandria response body: #{error.response_body}") if error.response_body.present?
      end

      def monotonic_now
        Process.clock_gettime(Process::CLOCK_MONOTONIC)
      end

      def elapsed_since(started_at)
        (monotonic_now - started_at).round(1)
      end

      def api_uri
        path = [
          ALEXANDRIA_BASE_URL,
          PUBLISH_URL
        ].join

        URI(path)
      end

      def conn
        @conn ||= Faraday.new(
          headers: { 'Content-Type' => 'application/json' },
          request: { open_timeout: OPEN_TIMEOUT, timeout: READ_TIMEOUT }
        ) do |faraday|
          faraday.response(:logger, logger) do |filter|
            filter.filter(/(Token token=\\")(\w+)/, '\1[REMOVED]')
          end
          faraday.response(:raise_error)
          faraday.adapter(Faraday.default_adapter)
          faraday.request(:authorization, 'Bearer', ALEXANDRIA_SERVICE_API_TOKEN)
          # NOTE: faraday-retry's default `methods` excludes POST, so this does
          # not actually retry the publish. Left as-is to avoid silently
          # introducing (non-idempotent) publish retries; the timeouts above are
          # what stop a hung Alexandria from blocking CI forever.
          faraday.request(:retry)
        end
      end

      def payload
        @payload ||= { content_module: }.to_json
      end
    end
  end
end
