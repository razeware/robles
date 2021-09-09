# frozen_string_literal: true

require 'irb'
require 'guard'
require 'guard/commander' # needed because of https://github.com/guard/guard/issues/793

# CLI for managing pablo
class PabloCli < Thor
  desc 'serve', 'starts local preview server'
  def serve
    fork do
      Guard.start(no_interactions: true)
    end
    RoblesPabloServer.run!
  end

  desc 'publish', 'renders and publishes pablo'
  option :source, type: :string, desc: 'Directory to scan for input images'
  option :output, type: :string, desc: 'Output directory for static site'
  def publish
    runner.publish_pablo(source: options['source'], output: options['output'])
  end

  private

  def runner
    Runner::Base.runner
  end

  def book_guardfile
    <<~GUARDFILE
      guard 'livereload' do
        watch(%r{[a-zA-Z0-9\-_]+\.yaml$})
        watch(%r{.+\.(md|markdown)$})
      end
    GUARDFILE
  end
end
