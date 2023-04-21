# frozen_string_literal: true

module Ci
  # A way to transmit linting data back to GitHub
  class LintingReporter
    attr_reader :check_run

    def initialize
      p github_event
    end

    def record_start
      return unless valid?

      @check_run = client.create_check_run(
        GITHUB_REPOSITORY,
        'robles Linter',
        head_sha,
        status: 'in_progress',
        started_at: Time.now.utc.iso8601
      )
    end

    def record_end(output)
      return unless valid?

      client.update_check_run(
        GITHUB_REPOSITORY,
        check_run.id,
        conclusion: output.validated ? 'success' : 'failure',
        output: output.to_h,
        status: 'completed',
        completed_at: Time.now.utc.iso8601
      )
    end

    def valid?
      GITHUB_REPOSITORY.present? &&
        GITHUB_SHA.present? &&
        GITHUB_EVENT_NAME == 'pull_request'
    end

    def head_sha
      @head_sha ||= github_event.dig('pull_request', 'head', 'sha')
    end

    def github_event
      @github_event ||= JSON.parse(File.read(GITHUB_EVENT_PATH))
    end

    def client
      @client ||= begin
        Octokit.middleware = middleware
        Octokit::Client.new(access_token: GITHUB_TOKEN)
      end
    end

    def middleware
      @middleware ||= Faraday::RackBuilder.new do |builder|
        builder.use Octokit::Middleware::FollowRedirects
        builder.use Octokit::Response::RaiseError
        builder.use Octokit::Response::FeedParser
        builder.response :logger, nil, { headers: true, bodies: true }
        builder.adapter Faraday.default_adapter
      end
    end
  end
end
