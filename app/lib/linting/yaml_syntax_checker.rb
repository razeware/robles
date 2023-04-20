# frozen_string_literal: true

module Linting
  # Provides methods to check whether images exist
  module YamlSyntaxChecker
    # Given a file, check whether it is valid YAML. If it is not valid return
    # the error, with line specified and error highlighted
    def valid_yaml?(file)
      Psych.load_file(file, permitted_classes: [Date])
      nil
    rescue Psych::SyntaxError => e
      "#{e.problem}, line #{e.line}, column #{e.column} (#{e.context})"
    end
  end
end
