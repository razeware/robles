# frozen_string_literal: true

# CLI for managing books
class VideoCli < Thor
  desc 'render', 'renders video course'
  option :'release-file', type: :string, desc: 'Location of the release.yaml file'
  option :local, type: :boolean
  def render
    runner.render_video_course(release_file: options['release_file'], local: options['local'])
  end

  desc 'serve', 'starts local preview server'
  option :dev, type: :boolean, desc: 'Run in development mode (watch robles files, not book files)'
  def serve
    fork do
      if options[:dev]
        Guard.start(no_interactions: true)
      else
        Guard.start(guardfile_contents: video_guardfile, watchdir: '/data/src', no_interactions: true)
      end
    end
    RoblesVideoServer.run!
  end

  desc 'console [RELEASE_FILE]', 'opens an interactive Ruby console'
  option :'release-file', type: :string, desc: 'Location of the release.yaml file'
  def console
    release_file = options.fetch('release_file', runner.default_release_file)
    parser = Parser::Release.new(file: release_file)
    video_course = parser.parse
    binding.irb # rubocop:disable Lint/Debugger
  end

  desc 'upload [RELEASE_FILE]', 'uploads a video course to betamax'
  option :'release-file', type: :string, desc: 'Location of the release.yaml file'
  def upload
    runner.upload_video_course(release_file: options['release_file'])
  end

  desc 'lint [RELEASE_FILE]', 'runs a selection of linters on the video course'
  option :'release-file', type: :string, desc: 'Location of the release.yaml file'
  method_option :'without-version', type: :boolean, aliases: '-e', default: false, desc: 'Run linting without git branch naming check'
  method_option :silent, type: :boolean, aliases: '-s', default: false, desc: 'Hide all output'
  def lint
    output = runner.lint_video_course(release_file: options['publish_file'], options:)
    exit 1 unless output.validated || ENVIRONMENT == 'staging'
  end

  desc 'slides [RELEASE_FILE]', 'generates slides to be inserted at beginning of video'
  option :'release-file', type: :string, desc: 'Location of the release.yaml file'
  option :app_host, type: :string, default: 'app', desc: 'Hostname of host running robles app server'
  option :app_port, type: :string, default: '4567', desc: 'Port of host running robles app server'
  option :snapshot_host, type: :string, default: 'snapshot', desc: 'Hostname of host running headless chrome'
  option :snapshot_port, type: :string, default: '3000', desc: 'Port of host running headless chrome'
  option :out_dir, type: :string, default: '/data/src/artwork/slides', desc: 'Location to save the output slides'
  def slides
    release_file = options.fetch('release_file', runner.default_release_file)
    parser = Parser::Release.new(file: release_file)
    video_course = parser.parse
    args = options.merge(data: video_course.parts.flat_map(&:episodes)).symbolize_keys
    snapshotter = Snapshotter::VideoCourseSlides.new(**args)
    snapshotter.generate
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
    REPO_AWS_ACCESS_KEY_ID_PRODUCTION=
    REPO_AWS_ACCESS_KEY_ID_STAGING=
    REPO_AWS_SECRET_ACCESS_KEY_PRODUCTION=
    REPO_AWS_SECRET_ACCESS_KEY_STAGING=
    REPO_SLACK_BOT_TOKEN=
    REPO_SLACK_WEBHOOK_URL=
  LONGDESC
  def secrets(repo)
    secrets_manager = RepoManagement::Secrets.new(repo:, mode: :video_course)
    secrets_manager.apply_secrets
  end

  private

  def runner
    Runner::Base.runner
  end

  def video_guardfile
    <<~GUARDFILE
      guard 'livereload' do
        watch(%r{[a-zA-Z0-9\-_]+.yaml$})
      end
    GUARDFILE
  end
end
