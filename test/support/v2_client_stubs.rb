# frozen_string_literal: true

# Helpers for testing Api::V2Client and the code that calls it, without a
# network or a stubbing library (robles has neither Mocha nor WebMock, and
# minitest 6 no longer ships minitest/mock). Shared with WEB-8206.
module V2ClientStubs
  # Both made up
  KST_TOKEN = "kst_robles_#{'a' * 43}".freeze
  SHARED_TOKEN = 'shared-token'

  JSON_HEADERS = { 'Content-Type' => 'application/json' }.freeze

  # Hand-made error bodies in the API v2 error envelope. The messages and
  # details are made up.
  BAD_REQUEST_BODY = '{"error":{"code":"bad_request","message":"Fixture: the book has no sku"}}'
  UNAUTHORIZED_BODY = '{"error":{"code":"unauthorized","message":"Fixture: token refused"}}'
  VALIDATION_FAILED_BODY = '{"error":{"code":"validation_failed","message":"Fixture: some fields are wrong","details":{"level":["fixture detail: not a known level"]}}}'
  INTERNAL_ERROR_BODY = '{"error":{"code":"internal_error","message":"Fixture: server fault"}}'

  # A client on Faraday's test adapter. It answers every POST with
  # `handler.call(env)`, a [status, headers, body] triple, and records each
  # env in @requests.
  def v2_test_client(&handler)
    @requests = []
    stubs = Faraday::Adapter::Test::Stubs.new do |stub|
      stub.post(/.*/) do |env|
        @requests << env
        handler.call(env)
      end
    end
    Api::V2Client.new(base_url: 'https://alexandria.test', token: KST_TOKEN, adapter: [:test, stubs])
  end

  def alexandria_api_v2_fixture(name)
    File.read(File.expand_path("../fixtures/alexandria_api_v2/#{name}", __dir__))
  end
end
