# frozen_string_literal: true

module Ci
  # A way to transmit linting data back to GitHub
  class LintingReporter
    attr_reader :check_run

    def record_start
      return unless valid?

      @check_run = client.create_check_run(
        GITHUB_REPOSITORY,
        'robles Linter',
        GITHUB_SHA,
        status: 'in_progress'
      )
    end

    def record_end(output)
      return unless valid?

      client.update_check_run(
        GITHUB_REPOSITORY,
        check_run.id,
        conclusion: output.validated ? 'success' : 'failure',
        output: output.to_h
      )
    end

    def valid?
      GITHUB_REPOSITORY.present? &&
        GITHUB_SHA.present? &&
        GITHUB_EVENT_NAME == 'pull_request'
    end

    def client
      @client ||= Octokit::Client.new(access_token: GITHUB_TOKEN)
    end
  end
end
