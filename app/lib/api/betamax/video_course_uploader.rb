# frozen_string_literal: true

module Api
  module Betamax
    # Allow uploading of video courses to betamax.
    #
    # WEB-8206: uploads go to betamax's API v2 endpoint,
    # POST /api/v2/collections/upload, which needs the `content:write` scope.
    # Since WEB-8371, BETAMAX_SERVICE_API_TOKEN must be robles's `kst_` token:
    # any other token, or none, is refused before a request is made.
    class VideoCourseUploader
      include Util::Logging

      attr_reader :video_course

      V2_UPLOAD_PATH = '/api/v2/collections/upload'
      # Net::HTTP's default read timeout, which uploads have always had:
      # storing a big course takes a while.
      V2_TIMEOUT = 60

      def self.upload(video_course)
        new(video_course).upload
      end

      # In a real run `token` is always BETAMAX_SERVICE_API_TOKEN. The keywords
      # let the tests supply a token and a client.
      def initialize(video_course, token: BETAMAX_SERVICE_API_TOKEN, client: nil)
        @video_course = video_course
        @token = token
        @client = client
      end

      # The body is the one v1 took. Errors aren't rescued: the runner reports
      # them to Slack and fails the step.
      def upload
        Api::V2Client.require_service_token!(@token, name: 'BETAMAX_SERVICE_API_TOKEN', service: 'betamax')
        response = client.post(V2_UPLOAD_PATH, payload)
        collection_id = response.data['id'] if response.data.is_a?(Hash)
        logger.info("Uploaded video course #{video_course.shortcode} #{video_course.version} to betamax API v2: collection #{collection_id}")
        response
      end

      private

      # Built lazily, after the token check
      def client
        @client ||= Api::V2Client.new(base_url: BETAMAX_BASE_URL, token: @token, timeout: V2_TIMEOUT)
      end

      def payload
        { video_course: }.to_json
      end
    end
  end
end
