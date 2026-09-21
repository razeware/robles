# frozen_string_literal: true

require_relative '../../test_helper'

require 'tmpdir'

module Linting
  module Metadata
    # Exercises the real linter against real git repositories (no stubbing), so
    # the remote parsing and the `Git.open` lookup are both covered.
    class RepoNameTest < Minitest::Test
      # Builds a throwaway git repo containing `metadata.yaml`, optionally with
      # an `origin` remote, and yields the path to the yaml file.
      def with_repo(remote: nil, contents: "sku: alg\nedition: 1.0\n")
        Dir.mktmpdir do |dir|
          git = Git.init(dir)
          git.remote_add('origin', remote) if remote
          file = File.join(dir, 'metadata.yaml')
          File.write(file, contents)
          yield file
        end
      end

      def lint(file:, identifier_attribute: :sku, prefix: nil, attributes: nil)
        attributes ||= Psych.load_file(file, permitted_classes: [Date]).deep_symbolize_keys
        RepoName.lint(file:, attributes:, identifier_attribute:, prefix:)
      end

      # --- books -------------------------------------------------------------

      def test_book_sku_matching_the_repo_name_passes
        with_repo(remote: 'git@github.com:kodecocodes/alg.git') do |file|
          assert_empty lint(file:)
        end
      end

      def test_book_sku_not_matching_the_repo_name_fails
        with_repo(remote: 'git@github.com:kodecocodes/not-alg.git') do |file|
          annotations = lint(file:)

          assert_equal 1, annotations.length
          assert_equal 'failure', annotations.first.annotation_level
          assert_equal 'Invalid sku specified', annotations.first.title
          assert_match 'not-alg', annotations.first.message
        end
      end

      def test_the_organisation_is_not_compared
        with_repo(remote: 'git@github.com:some-other-org/alg.git') do |file|
          assert_empty lint(file:), 'only the repo name should be compared, not the org'
        end
      end

      def test_https_remotes_are_understood
        with_repo(remote: 'https://github.com/kodecocodes/alg') do |file|
          assert_empty lint(file:)
        end
      end

      # --- modules -----------------------------------------------------------

      def test_module_shortcode_matching_the_prefixed_repo_name_passes
        with_repo(remote: 'git@github.com:kodecocodes/m3-devtest.git', contents: "shortcode: devtest\n") do |file|
          assert_empty lint(file:, identifier_attribute: :shortcode, prefix: 'm3-')
        end
      end

      def test_module_shortcode_without_the_prefix_fails
        with_repo(remote: 'git@github.com:kodecocodes/devtest.git', contents: "shortcode: devtest\n") do |file|
          annotations = lint(file:, identifier_attribute: :shortcode, prefix: 'm3-')

          assert_equal 1, annotations.length
          assert_match 'm3-devtest', annotations.first.message
        end
      end

      def test_module_shortcode_not_matching_the_repo_name_fails
        with_repo(remote: 'git@github.com:kodecocodes/m3-something-else.git', contents: "shortcode: devtest\n") do |file|
          refute_empty lint(file:, identifier_attribute: :shortcode, prefix: 'm3-')
        end
      end

      # --- inert cases -------------------------------------------------------

      def test_a_repo_without_a_remote_is_skipped
        with_repo do |file|
          assert_empty lint(file:), 'nothing to compare against without a remote'
        end
      end

      def test_a_blank_identifier_is_left_to_the_required_attribute_linter
        with_repo(remote: 'git@github.com:kodecocodes/alg.git', contents: "edition: 1.0\n") do |file|
          assert_empty lint(file:), 'a missing sku is already reported elsewhere'
        end
      end

      # --- annotation positioning -------------------------------------------

      def test_the_annotation_points_at_the_identifier
        contents = "title: Algorithms\nsku: alg\nedition: 1.0\n"
        with_repo(remote: 'git@github.com:kodecocodes/wrong.git', contents:) do |file|
          annotation = lint(file:).first

          assert_equal 2, annotation.start_line
          assert_equal 2, annotation.end_line
          assert_equal 6, annotation.start_column
          assert_equal 9, annotation.end_column
        end
      end

      def test_recommended_skus_is_not_mistaken_for_the_sku
        contents = "recommended_skus:\n  - other\nsku: alg\n"
        with_repo(remote: 'git@github.com:kodecocodes/wrong.git', contents:) do |file|
          annotation = lint(file:).first

          assert_equal 3, annotation.start_line
        end
      end

      # --- url parsing -------------------------------------------------------

      def test_name_from_url_handles_the_shapes_git_uses
        {
          'git@github.com:kodecocodes/m3-devtest.git' => 'm3-devtest',
          'git@github.com:kodecocodes/m3-devtest' => 'm3-devtest',
          'https://github.com/kodecocodes/m3-devtest.git' => 'm3-devtest',
          'https://github.com/kodecocodes/m3-devtest' => 'm3-devtest',
          'https://github.com/kodecocodes/m3-devtest/' => 'm3-devtest',
          'ssh://git@github.com/kodecocodes/m3-devtest.git' => 'm3-devtest'
        }.each do |url, expected|
          assert_equal expected, RepoName.name_from_url(url), "failed for #{url.inspect}"
        end
      end

      def test_name_from_url_returns_nothing_for_a_missing_url
        assert_nil RepoName.name_from_url('')
        assert_nil RepoName.name_from_url(nil)
      end
    end
  end
end
