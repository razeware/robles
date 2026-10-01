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
    #
    # Being unable to work out the repo name is a failure too, rather than a
    # reason to skip the check: every content type needs a readable git repo to
    # be parsed at all, so there's no legitimate lint run without one, and a
    # silent skip would look exactly like a verified match.
    class RepoName
      UNREADABLE_REPOSITORY = 'git refused to read the repository. That usually means it belongs to a ' \
                              "different user (as with a Docker bind mount) and needs adding to git's safe.directory"

      attr_reader :file, :attributes, :identifier_attribute, :prefix, :unverifiable_reason

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
        return [unverifiable_annotation] if repo_name.blank?
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

        url = remote_url
        @repo_name = self.class.name_from_url(url)
        @unverifiable_reason ||= "its remote URL (#{url}) doesn't name a repository" if @repo_name.blank?
        @repo_name
      end

      # The `origin` remote, falling back to whichever remote is configured.
      # When there isn't one to read, `unverifiable_reason` says why.
      def remote_url
        remotes = Git.open(directory).remote_list
        remote = remotes.find { _1.name == 'origin' } || remotes.first
        @unverifiable_reason = 'the repository has no git remote' if remote.nil?
        # A remote can carry more than one fetch URL; the first is the one git
        # itself treats as canonical.
        Array(remote&.url).first
      rescue ArgumentError
        # The git gem reports a repo that git refuses to read exactly as it
        # reports no repo at all, so tell the two apart here.
        @unverifiable_reason = inside_git_repository? ? UNREADABLE_REPOSITORY : 'it is not in a git repository'
        nil
      rescue StandardError => e
        @unverifiable_reason = "git couldn't read the repository (#{e.message.lines.first&.strip})"
        nil
      end

      def directory
        Pathname.new(file).expand_path.dirname
      end

      def inside_git_repository?
        directory.ascend.any? { _1.join('.git').exist? }
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

      def unverifiable_annotation
        Linting::Annotation.new(
          locate_identifier_reference.merge(
            absolute_path: file,
            annotation_level: 'failure',
            message: "Couldn't check the #{identifier_attribute} attribute in #{Pathname.new(file).basename} (#{identifier_from_metadata}) against the name of the\nrepository, because #{unverifiable_reason}.",
            title: "Unable to verify #{identifier_attribute}"
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
