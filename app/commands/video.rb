# frozen_string_literal: true

# CLI for managing books
class Video < Thor
  desc 'render', 'renders book'
  option :'release-file', type: :string, desc: 'Location of the release.yaml file'
  option :local, type: :boolean
  def render
    p 'render'
  end

  desc 'console [RELEASE_FILE]', 'opens an interactive Ruby console'
  option :'release-file', type: :string, desc: 'Location of the release.yaml file'
  def console
    p 'console'
  end

  desc 'upload [RELEASE_FILE]', 'uploads a video course to betamax'
  option :'release-file', type: :string, desc: 'Location of the release.yaml file'
  def publish
    p 'console'
  end

  desc 'lint [RELEASE_FILE]', 'runs a selection of linters on the video course'
  option :'release-file', type: :string, desc: 'Location of the release.yaml file'
  method_options 'without-version': :boolean, aliases: '-e', default: false, desc: 'Run linting without git branch naming check'
  method_options silent: :boolean, aliases: '-s', default: false, desc: 'Hide all output'
  def lint
    p 'lint'
  end

  desc 'secrets [REPO]', 'configures a video repo with the necessary secrets'
  long_desc <<-LONGDESC
    `robles secrets [REPO]` will upload the secrets requires to run robles on a
    git repository containing a video course.

    You must ensure that the required secrets are provided as environment variables
    before running this command:
    
    GITHUB_TOKEN=
    REPO_BETAMAX_SERVICE_API_TOKEN_PRODUCTION=
    REPO_BETAMAX_SERVICE_API_TOKEN_STAGING=
    REPO_SLACK_BOT_TOKEN=
    REPO_SLACK_WEBHOOK_URL=
  LONGDESC
  def secrets(repo)
    p 'secrets'
  end

  private

  def runner
    Runner::Base.runner
  end
end
