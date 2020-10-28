# frozen_string_literal: true

# Overall CLI app for robles
class RoblesCli < Thor
  # Ensures that invalid arguments etc result in a failure response to the shell
  def self.exit_on_failure?
    true
  end

  desc 'book SUBCOMMAND ...ARGS', 'manage publication of books'
  subcommand 'book', Book

  desc 'video SUBCOMMAND ...ARGS', 'manage publication of videos'
  subcommand 'video', Video
end
