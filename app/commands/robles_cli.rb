# frozen_string_literal: true

# Overall CLI app for robles
class RoblesCli < Thor
  # Ensures that invalid arguments etc result in a failure response to the shell
  def self.exit_on_failure?
    true
  end

  desc 'book [SUBCOMMAND] ...ARGS', 'manage publication of books'
  subcommand 'book', BookCli

  desc 'video [SUBCOMMAND] ...ARGS', 'manage publication of videos'
  subcommand 'video', VideoCli

  desc 'module [SUBCOMMAND] ...ARGS', 'manage publication of content modules'
  subcommand 'lo', ContentModuleCli

  desc 'pablo [SUBCOMMAND] ...ARGS', 'manage publication of pablo'
  subcommand 'pablo', PabloCli

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
