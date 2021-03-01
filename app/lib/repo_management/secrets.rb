# frozen_string_literal: true

module RepoManagement
  # Set secrets for GitHub Actions on a specified repo
  class Secrets
    DEFAULT_BOOK_SECRETS = {
      alexandria_service_api_token_production: REPO_ALEXANDRIA_SERVICE_API_TOKEN_PRODUCTION,
      alexandria_service_api_token_staging: REPO_ALEXANDRIA_SERVICE_API_TOKEN_STAGING,
      aws_access_key_id_production: REPO_AWS_ACCESS_KEY_ID_PRODUCTION,
      aws_access_key_id_staging: REPO_AWS_ACCESS_KEY_ID_STAGING,
      aws_secret_access_key_production: REPO_AWS_SECRET_ACCESS_KEY_PRODUCTION,
      aws_secret_access_key_staging: REPO_AWS_SECRET_ACCESS_KEY_STAGING,
      slack_bot_token: REPO_SLACK_BOT_TOKEN,
      slack_webhook_url: REPO_SLACK_WEBHOOK_URL
    }.freeze

    DEFAULT_VIDEO_COURSE_SECRETS = {
      betamax_service_api_token_production: REPO_BETAMAX_SERVICE_API_TOKEN_PRODUCTION,
      betamax_service_api_token_staging: REPO_BETAMAX_SERVICE_API_TOKEN_STAGING,
      aws_access_key_id_production: REPO_AWS_ACCESS_KEY_ID_PRODUCTION,
      aws_access_key_id_staging: REPO_AWS_ACCESS_KEY_ID_STAGING,
      aws_secret_access_key_production: REPO_AWS_SECRET_ACCESS_KEY_PRODUCTION,
      aws_secret_access_key_staging: REPO_AWS_SECRET_ACCESS_KEY_STAGING,
      slack_bot_token: REPO_SLACK_BOT_TOKEN,
      slack_webhook_url: REPO_SLACK_WEBHOOK_URL
    }.freeze

    attr_reader :repo, :secrets

    def initialize(repo:, mode:, secrets: {})
      @repo = repo
      default_secrets = mode == :video_course ? DEFAULT_VIDEO_COURSE_SECRETS : DEFAULT_BOOK_SECRETS
      @secrets = default_secrets.merge(secrets.symbolize_keys)
    end

    def secrets_valid?
      secrets.values.all?(&:present?)
    end

    def apply_secrets
      raise 'Missing secrets' unless secrets_valid?

      secrets.each { |key, value| apply_secret(key, value) }
    end

    def apply_secret(name, value)
      client.create_or_update_secret(repo, name.upcase, options_for_secret(value))
    end

    def options_for_secret(value)
      box = RbNaCl::Boxes::Sealed.from_public_key(key)
      encrypted_secret = box.encrypt(value)

      {
        encrypted_value: Base64.strict_encode64(encrypted_secret),
        key_id: public_key[:key_id]
      }
    end

    def key
      @key ||= begin
        decoded = Base64.decode64(public_key[:key])
        RbNaCl::PublicKey.new(decoded)
      end
    end

    def public_key
      @public_key ||= client.get_public_key(repo)
    end

    def client
      @client ||= begin
        Octokit.middleware = middleware
        Octokit::Client.new(access_token: GITHUB_TOKEN)
      end
    end

    def middleware
      @middleware ||= Faraday::RackBuilder.new do |builder|
        builder.use Faraday::Request::Retry, exceptions: [Octokit::ServerError]
        builder.use Octokit::Middleware::FollowRedirects
        builder.use Octokit::Response::RaiseError
        builder.use Octokit::Response::FeedParser
        builder.response :logger, nil, { headers: true, bodies: true }
        builder.adapter Faraday.default_adapter
      end
    end
  end
end
