# frozen_string_literal: true

module Util
  # Extract the git hash for the file repo
  module GitHashable
    include PathExtraction

    def git_hash
      Git.open(root_directory).log.first.sha
    end
  end
end
