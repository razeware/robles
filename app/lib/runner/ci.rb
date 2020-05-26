# frozen_string_literal: true

module Runner
  # For Continuous Integration
  class Ci
    def lint(publish_file:, options: {})
      reporter = Ci::LintingReporter.new
      reporter.record_start
      output = super(publish_file: publish_file, options: options.merge('without-edition' => GITHUB_EVENT_NAME == 'pull_request'))
      reporter.record_end(output)
    end

    def default_publish_file
      Pathname.new(GITHUB_WORKSPACE) + 'publish.yaml'
    end
  end
end
