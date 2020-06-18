# frozen_string_literal: true

# Overall CLI app for robles
class RoblesCli < Thor
  # Ensures that invalid arguments etc result in a failure response to the shell
  def self.exit_on_failure?
    true
  end

  desc 'render', 'renders book'
  option :'publish-file', type: :string, desc: 'Location of the publish.yaml file'
  option :local, type: :boolean
  def render
    book = runner.render(publish_file: options['publish_file'], local: options['local'])
    p book.sections.first.chapters.last
  end

  desc 'publish [PUBLISH_FILE]', 'renders and publishes a book'
  option :'publish-file', type: :string, desc: 'Location of the publish.yaml file'
  def publish
    runner.publish(publish_file: options['publish_file'])
  end

  desc 'lint [PUBLISH_FILE]', 'runs a selection of linters on the book'
  option :'publish-file', type: :string, desc: 'Location of the publish.yaml file'
  method_options 'without-edition': :boolean, aliases: '-e', default: false, desc: 'Run linting without git branch naming check'
  method_options silent: :boolean, aliases: '-s', default: false, desc: 'Hide all output'
  def lint
    output = runner.lint(publish_file: options['publish_file'], options: options)
    exit 1 unless output.validated
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
    secrets_manager = RepoManagement::Secrets.new(repo: repo)
    secrets_manager.apply_secrets
  end

  private

  def runner
    Runner::Base.runner
  end
end
