# frozen_string_literal: true

module Api
  module Betamax
    # Allow uploading of video courses to betamax
    class VideoCourseUploader
      include Util::Logging

      attr_reader :video_course

      UPLOAD_URL = '/api/v1/collections/upload'

      def self.upload(video_course)
        new(video_course).upload
      end

      def initialize(video_course)
        @video_course = video_course
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
          BETAMAX_BASE_URL,
          UPLOAD_URL
        ].join

        URI(path)
      end

      def conn
        @conn ||= Faraday.new(headers: { 'Content-Type' => 'application/json' }) do |faraday|
          faraday.response(:logger, logger) do |logger|
            logger.filter(/(Token token=\\\")(\w+)/, '\1[REMOVED]')
          end
          faraday.response(:raise_error)
          faraday.token_auth(BETAMAX_SERVICE_API_TOKEN)
          faraday.adapter(Faraday.default_adapter)
        end
      end

      def payload
        { video_course: video_course }.to_json
      end
    end
  end
end
