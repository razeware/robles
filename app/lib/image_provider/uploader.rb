# frozen_string_literal: true

module ImageProvider
  # Uploads images to S3.
  class Uploader
    attr_reader :root_path, :client

    def initialize(book_sku:, client: Aws::S3::Client.new(region: AWS_REGION))
      @root_path = "books/#{book_sku}/images"
      @client = client
    end

    def upload(representation)
      check_upload_status(representation)
      return if representation.uploaded

      client.put_object(
        bucket: AWS_BUCKET_NAME,
        body: representation.local_url,
        key: representation.key
      )
    end

    def check_upload_status(representation)
      return true if representation.uploaded

      representation.root_path ||= root_path

      response = client.list_objects_v2(
        bucket: AWS_BUCKET_NAME,
        max_keys: 1,
        prefix: representation.key
      )

      representation.uploaded = response.contents.count.positive?
    end
  end
end
