# frozen_string_literal: true

require 'stringio'
require_relative '../../test_helper'
require_relative '../../support/v2_client_stubs'

module Api
  module Alexandria
    class ContentModuleUploaderTest < Minitest::Test
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

      def test_shared_token_is_refused
        uploader = ContentModuleUploader.new(content_module, token: SHARED_TOKEN, client: UnusedClient.new(self))

        assert_token_refused('ALEXANDRIA_SERVICE_API_TOKEN', SHARED_TOKEN) { uploader.upload }
        refute_includes @log.string, 'Publishing content module'
      end

      # The test env sets no ALEXANDRIA_SERVICE_API_TOKEN
      def test_no_token_is_refused
        assert_token_refused('ALEXANDRIA_SERVICE_API_TOKEN', nil) { ContentModuleUploader.new(content_module).upload }
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

      def test_kst_token_timeout
        uploader = ContentModuleUploader.new(content_module, token: KST_TOKEN, client: v2_test_client { raise Faraday::TimeoutError, 'execution expired' })
        error = assert_raises(Api::V2Client::Error) { uploader.upload }

        refute_kind_of Faraday::Error, error
        assert_includes error.message, 'Faraday::TimeoutError'
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
