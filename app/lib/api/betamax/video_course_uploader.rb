# frozen_string_literal: true

module Api
  module Betamax
    # Allow uploading of video courses to betamax.
    #
    # WEB-8206: when BETAMAX_SERVICE_API_TOKEN is a service token (it starts
    # with `kst_`), the upload goes to betamax's API v2 endpoint,
    # POST /api/v2/collections/upload, which needs the `content:write` scope.
    # Any other token, or none, uses the v1 endpoint as before.
    class VideoCourseUploader
      include Util::Logging

      attr_reader :video_course

      UPLOAD_URL = '/api/v1/collections/upload'
      V2_UPLOAD_PATH = '/api/v2/collections/upload'
      # Net::HTTP's default read timeout, which v1 has always had: storing a
      # big course takes a while.
      V2_TIMEOUT = 60

      def self.upload(video_course)
        new(video_course).upload
      end

      # In a real run `token` is always BETAMAX_SERVICE_API_TOKEN. The keywords
      # let the tests choose a path.
      def initialize(video_course, token: BETAMAX_SERVICE_API_TOKEN, client: nil)
        @video_course = video_course
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

      # Sends v1's payload, so both paths send the same bytes. Errors aren't
      # rescued: the runner reports them to Slack and fails the step.
      def upload_with_api_v2
        response = client.post(V2_UPLOAD_PATH, payload)
        collection_id = response.data['id'] if response.data.is_a?(Hash)
        logger.info("Uploaded video course #{video_course.shortcode} #{video_course.version} to betamax API v2: collection #{collection_id}")
        response
      end

      # Built lazily, so the v1 path never builds it
      def client
        @client ||= Api::V2Client.new(base_url: BETAMAX_BASE_URL, token: @token, timeout: V2_TIMEOUT)
      end

      def api_uri
        path = [
          BETAMAX_BASE_URL,
          UPLOAD_URL
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
          faraday.request(:authorization, 'Bearer', BETAMAX_SERVICE_API_TOKEN)
          faraday.request(:retry)
        end
      end

      def payload
        { video_course: }.to_json
      end
    end
  end
end
