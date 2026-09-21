# frozen_string_literal: true

module Linting
  module Metadata
    # Confirm the repo name matches the appropriate identifier attribute.
    #
    # Books live in a repo named after their `sku`, modules in one named
    # `m3-<shortcode>`. Changing that identifier without moving the repo (almost
    # always an accident) would otherwise publish the content under the wrong
    # identity, so it's a linting failure. Only the repo name is compared--the
    # organisation the repo sits in is deliberately not checked.
    class RepoName
      attr_reader :file, :attributes, :identifier_attribute, :prefix

      def self.lint(file:, attributes:, identifier_attribute:, prefix: nil)
        new(file:, attributes:, identifier_attribute:, prefix:).lint
      end

      def initialize(file:, attributes:, identifier_attribute:, prefix: nil)
        @file = file
        @attributes = attributes
        @identifier_attribute = identifier_attribute
        @prefix = prefix
      end

      def lint
        # A missing identifier is already reported by the required attribute
        # linters--no need to say it twice.
        return [] if identifier_from_metadata.blank?
        # Nothing to compare against outside a git checkout with a remote.
        return [] if repo_name.blank?
        return [] if repo_name == expected_repo_name

        [error_annotation]
      end

      def expected_repo_name
        "#{prefix}#{identifier_from_metadata}"
      end

      def identifier_from_metadata
        @identifier_from_metadata ||= attributes[identifier_attribute]
      end

      def repo_name
        return @repo_name if defined?(@repo_name)

        @repo_name = self.class.name_from_url(remote_url)
      end

      # The `origin` remote, falling back to whichever remote is configured. Any
      # failure to read it (not a git repo, no remotes) leaves the check inert
      # rather than failing a lint run that has nothing to compare against.
      def remote_url
        remotes = Git.open(Pathname.new(file).dirname).remotes
        (remotes.find { _1.name == 'origin' } || remotes.first)&.url
      rescue StandardError
        nil
      end

      # Pulls `m3-devtest` out of any of the URL forms git uses, e.g.
      # `git@github.com:kodecocodes/m3-devtest.git` or
      # `https://github.com/kodecocodes/m3-devtest`.
      def self.name_from_url(url)
        return if url.blank?

        basename = url.to_s.strip.chomp('/').split(%r{[:/]}).last
        return if basename.blank?

        basename.delete_suffix('.git').presence
      end

      def error_annotation
        Linting::Annotation.new(
          locate_identifier_reference.merge(
            absolute_path: file,
            annotation_level: 'failure',
            message: "The #{identifier_attribute} attribute in #{Pathname.new(file).basename} (#{identifier_from_metadata}) means this repository should be\nnamed #{expected_repo_name}, but it is named #{repo_name}. Either correct the #{identifier_attribute}, or rename the repository.",
            title: "Invalid #{identifier_attribute} specified"
          )
        )
      end

      def locate_identifier_reference
        File.foreach(file).with_index do |line, line_number|
          next unless line.match?(/^\s*#{Regexp.escape(identifier_attribute.to_s)}:/)

          start_column = line.index(identifier_from_metadata.to_s)
          next if start_column.nil?

          return {
            start_line: line_number + 1,
            end_line: line_number + 1,
            start_column: start_column + 1,
            end_column: start_column + identifier_from_metadata.to_s.length + 1
          }
        end

        { start_line: 0, end_line: 0 }
      end
    end
  end
end
