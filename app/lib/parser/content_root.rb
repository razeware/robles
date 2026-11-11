# frozen_string_literal: true

module Parser
  # Every content file a book, module or course reads (its YAML, Markdown,
  # scripts, captions and assessments) has to be a regular file inside the
  # content root, just as its images do (see Util::ContentPath). The parsers
  # check each path as they build it, before anything is read or published.
  module ContentRoot
    # The directory holding publish.yaml, module.yaml or release.yaml
    def content_root
      root_directory
    end

    # Returns `path` as written if it's a regular file inside the content root.
    # Otherwise raises a Parser::Error against `named_in`, the YAML or script
    # file that names the path, so the linters report it as a failure.
    def content_file!(path, kind:, named_in:)
      return path if Util::ContentPath.resolve(content_root, path)

      raise Parser::Error.new(file: named_in, msg: Util::ContentPath.refusal(content_root, path, kind:))
    end
  end
end
