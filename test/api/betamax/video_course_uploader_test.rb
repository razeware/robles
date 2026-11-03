# frozen_string_literal: true

require 'stringio'
require_relative '../../test_helper'
require_relative '../../support/v2_client_stubs'

module Api
  module Betamax
    class VideoCourseUploaderTest < Minitest::Test
      include TestHelpers
      include V2ClientStubs

      V2_PATH = '/api/v2/collections/upload'

      # Hand-made error bodies in the API v2 error envelope, with made-up
      # messages and details
      BAD_REQUEST = '{"error":{"code":"bad_request","message":"Fixture: the course has no shortcode"}}'
      VALIDATION_FAILED = '{"error":{"code":"validation_failed","message":"Fixture: some values are wrong",' \
                          '"details":{"01":{"description":["fixture detail: missing"]}}}}'
      INTERNAL_ERROR = '{"error":{"code":"internal_error","message":"Fixture: server fault"}}'
      # Hand-made: a body that isn't in the API v2 envelope, as an unknown
      # route returns
      NOT_FOUND = '{"status":404,"error":"Fixture: not found"}'

      # Stands in for Api::V2Client on the v1 path, where it must never be used
      class UnusedClient
        def initialize(test)
          @test = test
        end

        def post(*)
          @test.flunk('the v1 path called the API v2 client')
        end
      end

      def setup
        @old_uploader_logger = VideoCourseUploader.logger
        @old_client_logger = Api::V2Client.logger
        @log = StringIO.new
        VideoCourseUploader.logger = Logger.new(@log)
        Api::V2Client.logger = Logger.new(@log)
      end

      def teardown
        VideoCourseUploader.logger = @old_uploader_logger
        Api::V2Client.logger = @old_client_logger
      end

      def course
        @course ||= VideoCourse.new(shortcode: 'ios101', version: '1.0', title: 'iOS 101 with Swift')
      end

      def v1_body
        { video_course: course }.to_json
      end

      # Hand-made: a minimal API v2 envelope with made-up values, holding only
      # what robles reads. betamax's own tests check the real response against
      # its spec.
      def betamax_fixture(name)
        File.read(fixture_path("betamax_api_v2/#{name}"))
      end

      def uploader_answering(status, body)
        VideoCourseUploader.new(course, token: KST_TOKEN, client: v2_test_client { [status, JSON_HEADERS, body] })
      end

      # v1's `conn` is memoised and robles has no stubbing library, so the tests
      # hand it a connection on Faraday's test adapter through @conn.
      def stub_v1(uploader)
        @v1_requests = []
        stubs = Faraday::Adapter::Test::Stubs.new do |stub|
          stub.post(/.*/) do |env|
            @v1_requests << env
            [200, JSON_HEADERS, '{}']
          end
        end
        uploader.instance_variable_set(:@conn, Faraday.new { |faraday| faraday.adapter(:test, stubs) })
        uploader
      end

      def assert_v1_upload
        assert_equal 1, @v1_requests.size
        request = @v1_requests.first
        assert_equal :post, request.method
        assert_equal '/api/v1/collections/upload', request.url.path
        assert_equal v1_body, request.request_body
      end

      def test_shared_token_uses_v1
        stub_v1(VideoCourseUploader.new(course, token: SHARED_TOKEN, client: UnusedClient.new(self))).upload

        assert_v1_upload
      end

      # The test environment sets no BETAMAX_SERVICE_API_TOKEN
      def test_no_token_uses_v1
        stub_v1(VideoCourseUploader.new(course, client: UnusedClient.new(self))).upload

        assert_v1_upload
      end

      def test_kst_token_uploads_to_v2
        uploader = uploader_answering(201, betamax_fixture('collection_upload.json'))
        response = uploader.upload

        assert_equal 201, response.status
        assert_equal 1, @requests.size
        request = @requests.first
        assert_equal :post, request.method
        assert_equal V2_PATH, request.url.path
        assert_equal "Bearer #{KST_TOKEN}", request.request_headers['Authorization']
        assert_equal v1_body, request.request_body
      end

      def test_kst_token_logs_and_never_builds_v1
        uploader = uploader_answering(201, betamax_fixture('collection_upload.json'))
        uploader.upload

        assert_includes @log.string, 'ios101 1.0'
        assert_includes @log.string, 'collection 301'
        assert_nil uploader.instance_variable_get(:@conn)
      end

      def test_kst_token_returns_nested_data
        response = uploader_answering(201, betamax_fixture('collection_with_associations.json')).upload

        assert_equal '01', response.data['parts'][0]['episodes'][0]['ref']
        assert_includes @log.string, 'collection 302'
      end

      def test_kst_token_bad_request
        error = assert_raises(Api::V2Client::Error) { uploader_answering(400, BAD_REQUEST).upload }

        assert_equal 400, error.status
        assert_equal 'bad_request', error.code
        assert_equal "POST #{V2_PATH} returned 400: Fixture: the course has no shortcode", error.message
      end

      def test_kst_token_validation_failed
        error = assert_raises(Api::V2Client::Error) { uploader_answering(422, VALIDATION_FAILED).upload }

        assert_equal 422, error.status
        assert_equal 'validation_failed', error.code
        assert_equal({ '01' => { 'description' => ['fixture detail: missing'] } }, error.details)
        assert_equal "POST #{V2_PATH} returned 422: Fixture: some values are wrong " \
                     '{"01":{"description":["fixture detail: missing"]}}', error.message
      end

      def test_kst_token_not_found
        error = assert_raises(Api::V2Client::Error) { uploader_answering(404, NOT_FOUND).upload }

        assert_equal 404, error.status
        assert_nil error.code
        assert_equal "POST #{V2_PATH} returned 404", error.message
      end

      def test_kst_token_server_error
        error = assert_raises(Api::V2Client::Error) { uploader_answering(500, INTERNAL_ERROR).upload }

        assert_equal 500, error.status
        assert_equal 1, @requests.size
      end

      def test_kst_token_timeout
        client = v2_test_client { raise Faraday::TimeoutError, 'execution expired' }
        uploader = VideoCourseUploader.new(course, token: KST_TOKEN, client:)
        error = assert_raises(Api::V2Client::Error) { uploader.upload }

        refute_kind_of Faraday::Error, error
        assert_includes error.message, 'Faraday::TimeoutError'
      end

      # robles has no stubbing library, so this test swaps Api::V2Client.new on
      # its singleton to record the keywords the uploader builds it with, and
      # removes the swap afterwards.
      def test_kst_token_builds_client
        client = v2_test_client { [201, JSON_HEADERS, betamax_fixture('collection_upload.json')] }
        built_with = nil
        Api::V2Client.singleton_class.define_method(:new) do |**kwargs|
          built_with = kwargs
          client
        end

        VideoCourseUploader.new(course, token: KST_TOKEN).upload

        assert_equal({ base_url: BETAMAX_BASE_URL, token: KST_TOKEN, timeout: 60 }, built_with)
      ensure
        Api::V2Client.singleton_class.remove_method(:new)
      end
    end
  end
end
