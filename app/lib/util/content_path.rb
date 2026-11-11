# frozen_string_literal: true

module Util
  # Book, module and course repos are written by authors, so robles only reads
  # an image, an SVG or a content file (Markdown, script, captions or YAML) that
  # is a regular file inside the content's own root: the directory holding
  # publish.yaml, module.yaml or release.yaml. Otherwise a `../` path or a
  # symlink could publish any file on the machine running the build. A symlink
  # that stays inside the root is fine.
  module ContentPath
    # Raised when an image is missing, isn't a regular file, or leads out of
    # the content root
    class InvalidPath < StandardError; end

    module_function

    # The real path of `path` if it's a regular file inside `root`, else nil
    def resolve(root, path)
      return if root.nil? || path.nil?

      real_root = File.realpath(root)
      real_path = File.realpath(path)
      real_path if real_path.start_with?("#{real_root}/") && File.file?(real_path)
    rescue SystemCallError
      nil
    end

    def check!(root, path)
      resolve(root, path) || raise(InvalidPath, refusal(root, path))
    end

    # `kind` names the sort of file, such as `chapter` or `script`
    def refusal(root, path, kind: 'image')
      message = "Refusing to publish: #{kind} #{relative(root, path)} isn't a regular file inside #{root}."
      "#{message} Check that it exists, and that no ../ path or symlink leads out of that directory."
    end

    # The path as written, relative to the root. Symlinks aren't followed, so
    # the message never names the file a symlink points at.
    def relative(root, path)
      return path.to_s if root.nil?

      Pathname.new(File.absolute_path(path)).relative_path_from(Pathname.new(File.absolute_path(root))).to_s
    end
  end
end
