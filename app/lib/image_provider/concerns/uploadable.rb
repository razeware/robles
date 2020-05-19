# frozen_string_literal: true

module ImageProvider
  # A concern that makes the selected class uploadable to AWS S3
  # Required methods: key, local_url
  module Uploadable
    extend ActiveSupport::Concern

    included do
      class_attribute :client, instance_predicate: false, default: Aws::S3::Client.new(region: AWS_REGION)
      validates :key, presence: true
    end

    def remote_url
      return unless uploaded? && IMAGES_CDN_HOST.present?

      "https://#{IMAGES_CDN_HOST}/#{key}"
    end

    def upload
      raise 'Need local_url to upload' unless local_url.present?
      return if uploaded?

      client.put_object(
        bucket: AWS_BUCKET_NAME,
        body: local_url,
        key: key
      )
    end

    def uploaded?
      validate!

      @uploaded ||= begin
        response = client.list_objects_v2(
          bucket: AWS_BUCKET_NAME,
          max_keys: 1,
          prefix: key
        )
        response.contents.count.positive?
      end
    end
  end
end
