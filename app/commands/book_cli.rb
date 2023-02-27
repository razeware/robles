# frozen_string_literal: true

require 'irb'
require 'guard'
require 'guard/commander' # needed because of https://github.com/guard/guard/issues/793

# CLI for managing books
class BookCli < Thor
  desc 'render', 'renders book'
  option :'publish-file', type: :string, desc: 'Location of the publish.yaml file'
  option :local, type: :boolean
  def render
    book = runner.render_book(publish_file: options['publish_file'], local: options['local'])
    p book.cover_image_url.to_json
  end

  desc 'serve', 'starts local preview server'
  option :dev, type: :boolean, desc: 'Run in development mode (watch robles files, not book files)'
  def serve
    fork do
      if options[:dev]
        Guard.start(no_interactions: true)
      else
        Guard.start(guardfile_contents: book_guardfile, watchdir: '/data/src', no_interactions: true)
      end
    end
    RoblesBookServer.run!
  end

  desc 'console [PUBLISH_FILE]', 'opens an interactive Ruby console'
  option :'publish-file', type: :string, desc: 'Location of the publish.yaml file'
  def console
    publish_file = options.fetch('publish_file', runner.default_publish_file)
    parser = Parser::Publish.new(file: publish_file)
    book = parser.parse
    binding.irb # rubocop:disable Lint/Debugger
  end

  desc 'publish [PUBLISH_FILE]', 'renders and publishes a book'
  option :'publish-file', type: :string, desc: 'Location of the publish.yaml file'
  def publish
    runner.publish_book(publish_file: options['publish_file'])
  end

  desc 'lint [PUBLISH_FILE]', 'runs a selection of linters on the book'
  option :'publish-file', type: :string, desc: 'Location of the publish.yaml file'
  method_options 'without-edition': :boolean, aliases: '-e', default: false, desc: 'Run linting without git branch naming check'
  method_options silent: :boolean, aliases: '-s', default: false, desc: 'Hide all output'
  def lint
    output = runner.lint_book(publish_file: options['publish_file'], options:)
    exit 1 unless output.validated || ENVIRONMENT == 'staging'
  end

  desc 'secrets [REPO]', 'configures a book repo with the necessary secrets'
  long_desc <<-LONGDESC
    `robles secrets [REPO]` will upload the secrets requires to run robles on a
    git repository containing a book.

    You must ensure that the required secrets are provided as environment variables
    before running this command:

    GITHUB_TOKEN=
    REPO_ALEXANDRIA_SERVICE_API_TOKEN_PRODUCTION=
    REPO_ALEXANDRIA_SERVICE_API_TOKEN_STAGING=
    REPO_AWS_ACCESS_KEY_ID_PRODUCTION=
    REPO_AWS_ACCESS_KEY_ID_STAGING=
    REPO_AWS_SECRET_ACCESS_KEY_PRODUCTION=
    REPO_AWS_SECRET_ACCESS_KEY_STAGING=
    REPO_SLACK_BOT_TOKEN=
    REPO_SLACK_WEBHOOK_URL=
  LONGDESC
  def secrets(repo)
    secrets_manager = RepoManagement::Secrets.new(repo:, mode: :book)
    secrets_manager.apply_secrets
  end

  private

  def runner
    Runner::Base.runner
  end

  def book_guardfile
    <<~GUARDFILE
      guard 'livereload' do
        watch(%r{[a-zA-Z0-9-_]+.yaml$})
        watch(%r{.+.(md|markdown)$})
      end
    GUARDFILE
  end
end
