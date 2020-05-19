# frozen_string_literal: true

module ImageProvider
  # A concern that makes the selected class uploadable to AWS S3
  # Required methods: key, local_url
  module Uploadable
    extend ActiveSupport::Concern

    included do
      class_attribute :s3, instance_predicate: false, default: Aws::S3::Resource.new(region: AWS_REGION)
      validates :key, presence: true
    end

    def remote_url
      return unless uploaded? && IMAGES_CDN_HOST.present?

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
