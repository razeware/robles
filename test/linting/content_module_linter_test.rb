# frozen_string_literal: true

require_relative '../test_helper'

require 'fileutils'
require 'tempfile'
require 'tmpdir'

module Linting
  # Runs the whole module linter over a module whose metadata is otherwise
  # clean, so the repo name check is the only thing that can object.
  class ContentModuleLinterTest < Minitest::Test
    include TestHelpers

    def with_module_repo(remote: 'git@github.com:kodecocodes/m3-devtest.git')
      Dir.mktmpdir do |dir|
        FileUtils.cp_r("#{fixture_path('repo_name_module')}/.", dir)
        Git.init(dir).remote_add('origin', remote)
        yield File.join(dir, 'module.yaml')
      end
    end

    def lint(file)
      ContentModuleLinter.new(file:).lint(options: { 'silent' => true, 'without-version' => true })
    end

    # Parsing records the module's git hash, so getting past metadata needs a commit
    def commit_everything(dir)
      repo = Git.open(dir)
      repo.config_set('user.name', 'robles test')
      repo.config_set('user.email', 'robles-test@example.com')
      repo.add(all: true)
      repo.commit('Fixture')
    end

    def test_the_metadata_of_the_fixture_is_otherwise_clean
      with_module_repo(remote: 'git@github.com:kodecocodes/m3-wrong.git') do |file|
        output = lint(file)

        assert_equal ['Invalid shortcode specified'], output.annotations.map(&:title)
      end
    end

    # The fixture has no ai_disclosure block. That is worth a warning, but a
    # warning alone must not fail lint, or every pre-policy module would.
    def test_a_missing_ai_disclosure_warns_without_failing_lint
      with_module_repo do |file|
        commit_everything(File.dirname(file))
        output = lint(file)

        assert output.validated
        levels_and_titles = output.annotations.map { [_1.annotation_level, _1.title] }

        assert_equal [['warning', 'Missing AI disclosure']], levels_and_titles
      end
    end

    # Git won't read a repo belonging to another user unless it's marked as a
    # safe.directory, which is what a Docker bind mount looks like from inside
    # the container. Parsing needs git too, so this used to get past metadata
    # and crash in the parser; it should stop at metadata and say why.
    def test_a_repo_git_refuses_to_read_fails_lint_instead_of_crashing
      skip 'needs root to change the repository owner' unless Process.uid.zero?

      with_module_repo do |file|
        FileUtils.chown_R('nobody', nil, File.dirname(file))

        Tempfile.create('gitconfig') do |config|
          env = { 'GIT_CONFIG_GLOBAL' => config.path, 'GIT_CONFIG_NOSYSTEM' => '1' }
          output = with_env(env) { lint(file) }

          refute output.validated
          assert_equal ['Unable to verify shortcode'], output.annotations.map(&:title)
          assert_match(/safe\.directory/, output.annotations.first.message)
        end
      end
    end

    def with_env(env)
      saved = ENV.to_h.slice(*env.keys)
      env.each { |key, value| ENV[key] = value }
      yield
    ensure
      env.each_key { |key| ENV[key] = saved[key] }
    end
  end
end
