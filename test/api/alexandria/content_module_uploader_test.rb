# frozen_string_literal: true

require 'stringio'
require_relative '../../test_helper'
require_relative '../../support/v2_client_stubs'

module Api
  module Alexandria
    class ContentModuleUploaderTest < Minitest::Test
      include TestHelpers
      include V2ClientStubs

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
        @log = StringIO.new
        @old_loggers = [ContentModuleUploader.logger, Api::V2Client.logger]
        ContentModuleUploader.logger = Logger.new(@log)
        Api::V2Client.logger = Logger.new(@log)
      end

      def teardown
        ContentModuleUploader.logger, Api::V2Client.logger = @old_loggers
      end

      def content_module
        @content_module ||= Parser::Circulate.new(file: fixture_path('ai_disclosure_module/module.yaml')).parse
      end

      # Hand-made: a minimal API v2 envelope with made-up values, holding only
      # what robles needs. alexandria's own tests check the real response
      # against its spec.
      def content_module_fixture
        alexandria_api_v2_fixture('content_module_publish.json')
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

      def test_shared_token_uses_v1
        uploader = stub_v1(ContentModuleUploader.new(content_module, token: SHARED_TOKEN, client: UnusedClient.new(self)))
        uploader.upload

        assert_equal 1, @v1_requests.size
        assert_equal '/api/content_modules/publish', @v1_requests.first.url.path
        refute_includes @log.string, 'Api::V2Client'
      end

      def test_no_token_uses_v1
        uploader = stub_v1(ContentModuleUploader.new(content_module, token: nil, client: UnusedClient.new(self)))
        uploader.upload

        assert_equal 1, @v1_requests.size
        assert_equal '/api/content_modules/publish', @v1_requests.first.url.path
      end

      def test_default_token_in_tests_uses_v1
        uploader = stub_v1(ContentModuleUploader.new(content_module))
        uploader.upload

        assert_equal '/api/content_modules/publish', @v1_requests.first.url.path
      end

      def test_kst_token_uses_v2
        uploader = ContentModuleUploader.new(content_module, token: KST_TOKEN, client: v2_test_client { [201, JSON_HEADERS, content_module_fixture] })
        response = uploader.upload

        assert_equal 201, response.status
        assert_equal 1, @requests.size
        request = @requests.first
        assert_equal :post, request.method
        assert_equal '/api/v2/content_modules/publish', request.url.path
        assert_equal uploader.send(:payload), request.request_body
      end

      def test_kst_token_logs_api_v2
        ContentModuleUploader.new(content_module, token: KST_TOKEN, client: v2_test_client { [201, JSON_HEADERS, content_module_fixture] }).upload

        assert_includes @log.string, "Publishing content module '#{content_module.shortcode}' to Alexandria API v2"
        assert_includes @log.string, 'Api::V2Client POST /api/v2/content_modules/publish 201'
      end

      def test_kst_token_never_builds_v1
        uploader = ContentModuleUploader.new(content_module, token: KST_TOKEN, client: v2_test_client { [201, JSON_HEADERS, content_module_fixture] })
        uploader.upload

        assert_nil uploader.instance_variable_get(:@conn)
      end

      def test_kst_token_validation_failed
        uploader = ContentModuleUploader.new(content_module, token: KST_TOKEN, client: v2_test_client { [422, JSON_HEADERS, VALIDATION_FAILED_BODY] })
        error = assert_raises(Api::V2Client::Error) { uploader.upload }

        assert_includes error.message, 'fixture detail: not a known level'
      end

      def test_kst_token_server_error
        uploader = ContentModuleUploader.new(content_module, token: KST_TOKEN, client: v2_test_client { [500, JSON_HEADERS, INTERNAL_ERROR_BODY] })
        assert_raises(Api::V2Client::Error) { uploader.upload }

        assert_equal 1, @requests.size
      end

      # v1's rescue logs "Alexandria publish failed"; its absence shows a v2
      # failure never goes through it.
      def test_kst_token_timeout_skips_v1_rescue
        uploader = ContentModuleUploader.new(content_module, token: KST_TOKEN, client: v2_test_client { raise Faraday::TimeoutError, 'execution expired' })
        assert_raises(Api::V2Client::Error) { uploader.upload }

        refute_includes @log.string, 'Alexandria publish failed'
      end

      # The test env sets no ALEXANDRIA_BASE_URL, so the real client refuses to
      # build before any request is made.
      def test_kst_token_with_real_client
        error = assert_raises(ArgumentError) { ContentModuleUploader.new(content_module, token: KST_TOKEN).upload }

        assert_equal 'base_url is required', error.message
      end
    end
  end
end
