# frozen_string_literal: true

# Overall CLI app for robles
class RoblesCli < Thor
  # Ensures that invalid arguments etc result in a failure response to the shell
  def self.exit_on_failure?
    true
  end

  desc 'book SUBCOMMAND ...ARGS', 'manage publication of books'
  subcommand 'book', BookCli

  desc 'video SUBCOMMAND ...ARGS', 'manage publication of videos'
  subcommand 'video', VideoCli

  ## We leave these in for now--they're deprecated. They should be removed later
  desc 'serve', '[DEPRECATED: use `robles book serve` instead] starts local preview server'
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

  desc 'lint [PUBLISH_FILE]', '[DEPRECATED: use `robles book lint` instead] runs a selection of linters on the book'
  option :'publish-file', type: :string, desc: 'Location of the publish.yaml file'
  method_options 'without-edition': :boolean, aliases: '-e', default: false, desc: 'Run linting without git branch naming check'
  method_options silent: :boolean, aliases: '-s', default: false, desc: 'Hide all output'
  def lint
    output = runner.lint_book(publish_file: options['publish_file'], options: options)
    exit 1 unless output.validated || ENVIRONMENT == 'staging'
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
