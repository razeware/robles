# frozen_string_literal: true

module Runner
  # For Continuous Integration
  class Ci < Runner::Base
    def lint(publish_file:, options: {})
      reporter = ::Ci::LintingReporter.new
      reporter.record_start
      output = super(publish_file:, options: options.merge('without-edition' => GITHUB_EVENT_NAME == 'pull_request'))
      reporter.record_end(output)
      output
    end

    def default_publish_file
      Pathname.new(GITHUB_WORKSPACE).join('publish.yaml').to_s
    end

    def default_release_file
      Pathname.new(GITHUB_WORKSPACE).join('release.yaml').to_s
    end

    def default_module_file
      Pathname.new(GITHUB_WORKSPACE).join('module.yaml').to_s
    end

    def default_pablo_source
      Pathname.new(GITHUB_WORKSPACE).join('images').to_s
    end

    def default_pablo_output
      Pathname.new(GITHUB_WORKSPACE).join('dist').to_s
    end
  end
end
