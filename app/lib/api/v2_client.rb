# frozen_string_literal: true

module Api
  # A small client for Kodeco's API v2 (WEB-8205 for alexandria, WEB-8206 for
  # betamax). robles is public and can't bundle the private guardpost_rails
  # gem, so this follows the API v2 client's rules for a POST: a bearer token,
  # `data` and `meta` from a 2xx, one error class carrying the body's `code`,
  # `message` and `details`, and a log line with no headers, body or token.
  class V2Client
    include Util::Logging

    # robles's API v2 token starts with this. It's the same prefix test
    # guardpost_rails uses to tell a service token apart. API v2 is the only
    # upload path, so any other token is refused before a request (WEB-8371).
    TOKEN_PREFIX = 'kst_'

    # Never includes the token, and names no people, channels or hosts,
    # because robles is public. It shows in the Actions log and in Slack.
    TOKEN_MESSAGE = "Can't publish to %<service>s: %<name>s is empty or isn't robles's API v2 token, " \
                    'which starts with "kst_". The old shared token no longer works. ' \
                    "Ask Kodeco engineering for robles's kst_ token, and save it in this repo's " \
                    '%<name>s_STAGING or %<name>s_PRODUCTION Actions secret.'

    # Raised before any request, so it isn't an Error
    class TokenError < StandardError; end

    def self.service_token?(token)
      token.is_a?(String) && token.start_with?(TOKEN_PREFIX)
    end

    def self.require_service_token!(token, name:, service:)
      return if service_token?(token)

      raise TokenError, format(TOKEN_MESSAGE, name:, service:)
    end

    Response = Data.define(:status, :data, :meta)

    class Error < StandardError
      attr_reader :status, :code, :details

      def initialize(message, status: nil, code: nil, details: nil)
        super(message)
        @status = status
        @code = code
        @details = details
      end
    end

    attr_reader :base_url

    # Generous timeouts, because publishing a whole module can be slow, but
    # bounded so a hung service fails instead of hanging CI. WEB-8206 passes
    # its own `timeout:`.
    def initialize(base_url:, token:, open_timeout: 10, timeout: 120, adapter: Faraday.default_adapter)
      raise ArgumentError, 'base_url is required' if base_url.blank?
      raise ArgumentError, 'token is required' if token.blank?

      @base_url = base_url
      @token = token
      @conn = Faraday.new(
        headers: { 'Accept' => 'application/json', 'Content-Type' => 'application/json' },
        request: { open_timeout:, timeout: }
      ) { |faraday| faraday.adapter(*Array(adapter)) }
    end

    # `body` is a JSON string, sent as it is. A POST is never retried, because
    # a publish isn't idempotent: alexandria records every attempt.
    def post(path, body)
      started_at = Process.clock_gettime(Process::CLOCK_MONOTONIC)
      response = request(path, body, started_at)
      log(path, response.status, started_at)
      handle(path, response)
    end

    def inspect
      "#<Api::V2Client #{base_url}>"
    end

    private

    def request(path, body, started_at)
      @conn.post(URI([base_url, path].join)) do |req|
        req.headers['Authorization'] = "Bearer #{@token}"
        req.body = body
      end
    rescue Faraday::Error => e
      log(path, e.is_a?(Faraday::TimeoutError) ? 'timeout' : 'failed', started_at)
      raise Error, "POST #{path} failed: #{e.class}: #{e.message}"
    end

    def handle(path, response)
      body = parse(response.body)
      return success(path, response.status, body) if response.status.between?(200, 299)

      error = body.is_a?(Hash) && body['error'].is_a?(Hash) ? body['error'] : {}
      raise Error.new(error_message(path, response.status, error), status: response.status, code: error['code'], details: error['details'])
    end

    def success(path, status, body)
      raise Error.new("POST #{path} returned #{status} without data", status:) unless body.is_a?(Hash) && body.key?('data')

      Response.new(status:, data: body['data'], meta: body['meta'] || {})
    end

    def error_message(path, status, error)
      message = "POST #{path} returned #{status}"
      message += ": #{error['message']}" if error['message'].present?
      message += " #{JSON.generate(error['details']).truncate(1000)}" if error['details'].present?
      message
    end

    def parse(body)
      JSON.parse(body.to_s)
    rescue JSON::ParserError
      nil
    end

    def log(path, status, started_at)
      ms = ((Process.clock_gettime(Process::CLOCK_MONOTONIC) - started_at) * 1000).round
      logger.info("Api::V2Client POST #{path} #{status} #{ms}ms")
    end
  end
end
