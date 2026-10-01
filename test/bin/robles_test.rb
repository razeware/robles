# frozen_string_literal: true

require_relative '../test_helper'

require 'open3'
require 'rbconfig'
require 'tempfile'

# Runs the real executable. `bin/robles` marks the content repo as a git
# safe.directory before anything else happens--without it git refuses to read a
# bind-mounted repo owned by another user, and every lint crashes. It writes to
# the global git config, so each run here is pointed at a throwaway one.
class RoblesExecutableTest < Minitest::Test
  EXECUTABLE = File.expand_path('../../bin/robles', __dir__)

  def run_robles(env = {})
    Tempfile.create('gitconfig') do |config|
      env = { 'GIT_CONFIG_GLOBAL' => config.path, 'GIT_CONFIG_NOSYSTEM' => '1', 'GITHUB_WORKSPACE' => nil }.merge(env)
      output, status = Open3.capture2e(env, RbConfig.ruby, EXECUTABLE, 'help')
      safe_directory, = Open3.capture2('git', 'config', '--file', config.path, '--get-all', 'safe.directory')

      yield output, status, safe_directory.lines.map(&:chomp)
    end
  end

  def test_marks_the_default_mount_point_as_a_safe_directory
    run_robles do |output, status, safe_directories|
      assert status.success?, output
      assert_equal ['/data/src'], safe_directories
    end
  end

  def test_marks_the_github_workspace_as_a_safe_directory_inside_actions
    run_robles('GITHUB_WORKSPACE' => '/github/workspace') do |output, status, safe_directories|
      assert status.success?, output
      assert_equal ['/github/workspace'], safe_directories
    end
  end

  # The git gem removes its deprecated APIs in v6, and it isn't pinned. Anything
  # here runs before the CLI's own error handling, so a removed method would
  # take down every command.
  def test_starts_without_any_git_deprecation_warnings
    run_robles do |output, _status, _safe_directories|
      refute_match(/DEPRECATION WARNING: Git/, output)
    end
  end
end
