# frozen_string_literal: true

module Runner
  # For Continuous Integration
  class Ci < Runner::Base
    # Linting in CI reports progress back to GitHub as a check run, and relaxes
    # the branch naming check on pull requests--a review branch isn't named for
    # the edition or version it carries.
    def lint_book(publish_file:, options: {})
      with_check_run { super(publish_file:, options: relax_branch_check(options, 'without-edition')) }
    end

    def lint_video_course(release_file:, options: {})
      with_check_run { super(release_file:, options: relax_branch_check(options, 'without-version')) }
    end

    def lint_content_module(module_file:, options: {})
      with_check_run { super(module_file:, options: relax_branch_check(options, 'without-version')) }
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

    private

    # Only ever turns the branch check off--an explicitly requested skip is left
    # alone on the other event types.
    def relax_branch_check(options, flag)
      return options unless GITHUB_EVENT_NAME == 'pull_request'

      options.merge(flag => true)
    end

    # The check run is a reporting side channel. A problem talking to GitHub
    # shouldn't turn a passing lint into a failing build, or mask a failing one.
    def with_check_run
      reporter = ::Ci::LintingReporter.new
      report(reporter, :record_start)
      output = yield
      report(reporter, :record_end, output)
      output
    end

    def report(reporter, method, *)
      reporter.send(method, *)
    rescue StandardError => e
      logger.warn("Unable to report linting status to GitHub: #{e.message}")
    end
  end
end
