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
  option :out_dir, type: :string, default: '/data/src/artwork/slides', desc: 'Location to save the output slides'
  def slides
    module_file = options.fetch('module_file', runner.default_module_file)
    parser = Parser::Circulate.new(file: module_file)
    content_module = parser.parse
    options.delete('module_file')
    args = options.merge(data: content_module.lessons.flat_map(&:segments), snapshot_host: 'localhost').symbolize_keys
    snapshotter = Snapshotter::Slides.new(**args)
    snapshotter.generate
  end


  desc 'serve', 'starts local preview server'
  option :dev, type: :boolean, desc: 'Run in development mode (watch robles files, not book files)'
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
