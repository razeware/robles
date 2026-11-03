# frozen_string_literal: true

require 'stringio'
require_relative '../test_helper'
require_relative '../support/v2_client_stubs'

module Api
  class V2ClientTest < Minitest::Test
    include TestHelpers
    include V2ClientStubs

    PATH = '/api/v2/editions/publish'
    BODY = '{"book":{"sku":"fixture-book"}}'

    def setup
      @old_logger = Api::V2Client.logger
      @log = StringIO.new
      Api::V2Client.logger = Logger.new(@log)
    end

    def teardown
      Api::V2Client.logger = @old_logger
    end

    # Hand-made: a minimal API v2 envelope with made-up values, holding only
    # what robles needs. alexandria's own tests check the real response
    # against its spec.
    def edition_fixture
      alexandria_api_v2_fixture('edition_publish.json')
    end

    def client_answering(status, body, headers = JSON_HEADERS)
      v2_test_client { |_env| [status, headers, body] }
    end

    def test_service_token
      assert Api::V2Client.service_token?(KST_TOKEN)
      refute Api::V2Client.service_token?(SHARED_TOKEN)
      refute Api::V2Client.service_token?(nil)
      refute Api::V2Client.service_token?('')
      refute Api::V2Client.service_token?("KST_robles_#{'a' * 43}")
    end

    def test_created_returns_data
      response = client_answering(201, edition_fixture).post(PATH, BODY)

      assert_equal 201, response.status
      assert_equal JSON.parse(edition_fixture)['data'], response.data
      assert_equal({}, response.meta)
    end

    def test_created_sends_one_request
      client_answering(201, edition_fixture).post(PATH, BODY)

      assert_equal 1, @requests.size
      request = @requests.first
      assert_equal :post, request.method
      assert_equal 'https://alexandria.test/api/v2/editions/publish', request.url.to_s
      assert_equal BODY, request.request_body
    end

    def test_created_sends_headers
      client_answering(201, edition_fixture).post(PATH, BODY)
      headers = @requests.first.request_headers

      assert_equal "Bearer #{KST_TOKEN}", headers['Authorization']
      assert_equal 'application/json', headers['Content-Type']
      assert_equal 'application/json', headers['Accept']
    end

    def test_validation_failed
      error = assert_raises(Api::V2Client::Error) { client_answering(422, VALIDATION_FAILED_BODY).post('/api/v2/content_modules/publish', BODY) }

      assert_equal 422, error.status
      assert_equal 'validation_failed', error.code
      assert_equal({ 'level' => ['fixture detail: not a known level'] }, error.details)
      assert_equal 'POST /api/v2/content_modules/publish returned 422: Fixture: some fields are wrong {"level":["fixture detail: not a known level"]}', error.message
    end

    def test_bad_request
      error = assert_raises(Api::V2Client::Error) { client_answering(400, BAD_REQUEST_BODY).post(PATH, BODY) }

      assert_equal 400, error.status
      assert error.message.end_with?('returned 400: Fixture: the book has no sku'), error.message
    end

    def test_unauthorized
      error = assert_raises(Api::V2Client::Error) { client_answering(401, UNAUTHORIZED_BODY).post(PATH, BODY) }

      assert_equal 401, error.status
      assert_equal 'unauthorized', error.code
    end

    def test_not_found_with_html_body
      client = client_answering(404, '<html><body>Not Found</body></html>', { 'Content-Type' => 'text/html' })
      error = assert_raises(Api::V2Client::Error) { client.post(PATH, BODY) }

      assert_equal 404, error.status
      assert_nil error.code
      assert_equal 'POST /api/v2/editions/publish returned 404', error.message
    end

    def test_server_errors_are_not_retried
      [[500, INTERNAL_ERROR_BODY], [503, '']].each do |status, body|
        client = client_answering(status, body)
        error = assert_raises(Api::V2Client::Error) { client.post(PATH, BODY) }

        assert_equal status, error.status
        assert_equal 1, @requests.size
      end
    end

    def test_timeout
      client = v2_test_client { |_env| raise Faraday::TimeoutError, 'execution expired' }
      error = assert_raises(StandardError) { client.post(PATH, BODY) }

      assert_instance_of Api::V2Client::Error, error
      refute_kind_of Faraday::Error, error
      assert_equal "POST #{PATH} failed: Faraday::TimeoutError: execution expired", error.message
      assert_equal 1, @requests.size
      assert_includes @log.string, "POST #{PATH} timeout"
    end

    def test_success_without_data
      error = assert_raises(Api::V2Client::Error) { client_answering(201, '{}').post(PATH, BODY) }

      assert_includes error.message, 'without data'
    end

    def test_long_details_are_cut
      body = JSON.generate(error: { code: 'validation_failed', message: 'Fixture: some fields are wrong', details: { title: ['x' * 5000] } })
      error = assert_raises(Api::V2Client::Error) { client_answering(422, body).post(PATH, BODY) }

      assert_operator error.message.length, :<=, 1100
      assert_equal 5000, error.details['title'].first.length
    end

    def test_blank_arguments
      assert_raises(ArgumentError) { Api::V2Client.new(base_url: 'https://alexandria.test', token: '') }
      assert_raises(ArgumentError) { Api::V2Client.new(base_url: 'https://alexandria.test', token: nil) }
      assert_raises(ArgumentError) { Api::V2Client.new(base_url: nil, token: KST_TOKEN) }
      assert_raises(ArgumentError) { Api::V2Client.new(base_url: '', token: KST_TOKEN) }
    end

    def test_logs_one_line_without_the_token
      client = client_answering(201, edition_fixture)
      client.post(PATH, BODY)

      lines = @log.string.lines
      assert_equal 1, lines.size
      assert_match(%r{POST /api/v2/editions/publish 201 \d+ms}, lines.first)
      refute_includes @log.string, KST_TOKEN
      refute_includes @log.string, 'alexandria.test'
      refute_includes client.inspect, KST_TOKEN
      assert_equal '#<Api::V2Client https://alexandria.test>', client.inspect
    end
  end
end
