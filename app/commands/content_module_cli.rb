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
  option :dev, type: :boolean, desc: 'Run in development mode (watch robles files, not book files)'
  def serve
    fork do
      if options[:dev]
        Guard.start(no_interactions: true)
      else
        Guard.start(guardfile_contents: content_module_guardfile, watchdir: '../m3-devtest', no_interactions: true)
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
