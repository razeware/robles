# frozen_string_literal: true

module Linting
  # Provides methods to check whether images exist
  module FileExistenceChecker
    # This method shouldn't depend on the underlying filesystem
    def file_exists?(path, case_insensitive: false)
      path = path.to_s
      directory_contents = Dir[Pathname.new(path).dirname.join('*')]
      return directory_contents.include?(path) unless case_insensitive

      directory_contents.map(&:downcase).include?(path.downcase)
    end
  end
end
