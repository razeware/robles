# frozen_string_literal: true

module ImageProvider
  module Concerns
    # A concern that makes the selected class uploadable to AWS S3
    # Required methods: key
    module Uploadable
      extend ActiveSupport::Concern

      attr_accessor :local_url, :local_server

      included do
        class_attribute :s3, instance_predicate: false, default: AWS_REGION.present? ? Aws::S3::Resource.new(region: AWS_REGION) : nil
        validates :key, presence: true
      end

      def remote_url
        return image&.local_url&.gsub(%r{/data/src}, '/assets') if local_server
        return unless IMAGES_CDN_HOST.present?

        "https://#{IMAGES_CDN_HOST}/#{key}"
      end

      def upload
        return if uploaded?
        raise 'Need local_url to upload' unless local_url.present?

        s3_object.upload_file(local_url)
      end

      def uploaded?
        validate!

        @uploaded ||= s3_object.exists?
      end

      def s3_object
        @s3_object ||= s3.bucket(AWS_BUCKET_NAME).object(key)
      end
    end
  end
end
