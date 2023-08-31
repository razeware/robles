# frozen_string_literal: true

# CLI for managing content module of a multi model learning path

class ContentModuleCli < Thor
  desc 'render', 'renders content modules'
  option :'module_file', type: :string, desc: 'Location of the module.yaml file'
  option :local, type: :boolean
  def render
    content_module = runner.render_content_module(module_file: options['module_file'], local: options['local'])
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
    RoblesModuleServer.run!
  end

  private

  def runner
    Runner::Base.runner
  end

  def video_guardfile
    <<~GUARDFILE
      guard 'livereload' do
        watch(%r{[a-zA-Z0-9-_]+.yaml$})
      end
    GUARDFILE
  end
end
