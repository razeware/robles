# frozen_string_literal: true

# CLI for managing content module of a multi model learning path

class ContentModuleCli < Thor
  desc 'render', 'renders content modules'
  option :module_file, type: :string, desc: 'Location of the module.yaml file'
  option :local, type: :boolean
  def render
    runner.render_content_module(module_file: options['module_file'], local: options['local'])
  end

  desc 'serve', 'starts local preview server'
  option :dev, type: :boolean, desc: 'Run in development mode (watch robles files, not module files)'
  def serve
    fork do
      if options[:dev]
        Guard.start(no_interactions: true)
      else
        Guard.start(guardfile_contents: content_module_guardfile, watchdir: '/data/src', no_interactions: true)
      end
    end
    RoblesContentModuleServer.run!
  end

  desc 'lint [MODULE_FILE]', 'runs a selection of linters on the module'
  option :module_file, type: :string, desc: 'Location of the module.yaml file'
  method_options 'without-version': :boolean, aliases: '-e', default: false, desc: 'Run linting without git branch naming check'
  method_options silent: :boolean, aliases: '-s', default: false, desc: 'Hide all output'
  def lint
    output = runner.lint_content_module(module_file: options['module_file'], options:)
    exit 1 unless output.validated || ENVIRONMENT == 'staging'
  end

  desc 'circulate [MODULE_FILE]', 'renders and circulates a content module'
  option :module_file, type: :string, desc: 'Location of the module.yaml file'
  def circulate
    runner.circulate_content_module(module_file: options['module_file'])
  end

  desc 'slides [MODULE_FILE]', 'generates slides to be inserted at beginning of video'
  option :module_file, type: :string, desc: 'Location of the module.yaml file'
  option :app_host, type: :string, default: 'app', desc: 'Hostname of host running robles app server'
  option :app_port, type: :string, default: '4567', desc: 'Port of host running robles app server'
  option :snapshot_host, type: :string, default: 'snapshot', desc: 'Hostname of host running headless chrome'
  option :snapshot_port, type: :string, default: '3000', desc: 'Port of host running headless chrome'
  option :out_dir, type: :string, default: '/data/src/artwork/video-title-slides', desc: 'Location to save the output slides'
  def slides
    module_file = options.fetch('module_file', runner.default_module_file)
    parser = Parser::Circulate.new(file: module_file)
    content_module = parser.parse
    options.delete('module_file')
    args = options.merge(data: content_module.lessons).symbolize_keys
    snapshotter = Snapshotter::ContentModuleSlides.new(**args)
    snapshotter.generate
  end


  desc 'serve', 'starts local preview server'
  option :dev, type: :boolean, desc: 'Run in development mode (watch robles files, not module files)'
  def serve
    fork do
      if options[:dev]
        Guard.start(no_interactions: true)
      else
        Guard.start(guardfile_contents: content_module_guardfile, watchdir: './', no_interactions: true)
      end
    end
    RoblesContentModuleServer.run!
  end

  desc 'secrets [REPO]', 'configures a module repo with the necessary secrets'
  long_desc <<-LONGDESC
    `robles module secrets [REPO]` will upload the secrets requires to run robles on a
    git repository containing a module.

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
    secrets_manager = RepoManagement::Secrets.new(repo:, mode: :content_module)
    secrets_manager.apply_secrets
  end

  private

  def runner
    Runner::Base.runner
  end

  def content_module_guardfile
    <<~GUARDFILE
      guard 'livereload' do
        watch(%r{[a-zA-Z0-9-_]+.yaml$})
      end
    GUARDFILE
  end
end
