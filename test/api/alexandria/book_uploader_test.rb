# frozen_string_literal: true

require 'stringio'
require_relative '../../test_helper'
require_relative '../../support/v2_client_stubs'

module Api
  module Alexandria
    class BookUploaderTest < Minitest::Test
      include TestHelpers
      include V2ClientStubs

      # Stands in for Api::V2Client when the token is refused, and fails the
      # test if it's called
      class UnusedClient
        def initialize(test)
          @test = test
        end

        def post(*)
          @test.flunk('a refused token called the API v2 client')
        end
      end

      def setup
        @old_logger = Api::V2Client.logger
        Api::V2Client.logger = Logger.new(StringIO.new)
      end

      def teardown
        Api::V2Client.logger = @old_logger
      end

      def book
        @book ||= Parser::Publish.new(file: fixture_path('ai_disclosure_book/publish.yaml')).parse
      end

      # Hand-made: a minimal API v2 envelope with made-up values, holding only
      # what robles needs. alexandria's own tests check the real response
      # against its spec.
      def edition_fixture
        alexandria_api_v2_fixture('edition_publish.json')
      end

      def test_shared_token_is_refused
        uploader = BookUploader.new(book, token: SHARED_TOKEN, client: UnusedClient.new(self))

        assert_token_refused('ALEXANDRIA_SERVICE_API_TOKEN', SHARED_TOKEN) { uploader.upload }
      end

      # The test env sets no ALEXANDRIA_SERVICE_API_TOKEN
      def test_no_token_is_refused
        assert_token_refused('ALEXANDRIA_SERVICE_API_TOKEN', nil) { BookUploader.new(book).upload }
      end

      def test_kst_token_uses_v2
        uploader = BookUploader.new(book, token: KST_TOKEN, client: v2_test_client { [201, JSON_HEADERS, edition_fixture] })
        response = uploader.upload

        assert_equal 201, response.status
        assert_equal 1, @requests.size
        request = @requests.first
        assert_equal :post, request.method
        assert_equal '/api/v2/editions/publish', request.url.path
        assert_equal uploader.send(:payload), request.request_body
      end

      def test_kst_token_validation_failed
        uploader = BookUploader.new(book, token: KST_TOKEN, client: v2_test_client { [422, JSON_HEADERS, VALIDATION_FAILED_BODY] })
        error = assert_raises(Api::V2Client::Error) { uploader.upload }

        assert_includes error.message, 'fixture detail: not a known level'
      end

      def test_kst_token_server_error
        uploader = BookUploader.new(book, token: KST_TOKEN, client: v2_test_client { [500, JSON_HEADERS, INTERNAL_ERROR_BODY] })
        assert_raises(Api::V2Client::Error) { uploader.upload }

        assert_equal 1, @requests.size
      end

      # The test env sets no ALEXANDRIA_BASE_URL, so the real client refuses to
      # build before any request is made.
      def test_kst_token_with_real_client
        error = assert_raises(ArgumentError) { BookUploader.new(book, token: KST_TOKEN).upload }

        assert_equal 'base_url is required', error.message
      end
    end
  end
end
