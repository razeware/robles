# frozen_string_literal: true

module Runner
  # For interactive mode
  class Interactive < Runner::Base
    def default_publish_file
      '/data/src/publish.yaml'
    end

    def default_release_file
      '/data/src/release.yaml'
    end

    def default_pablo_source
      '/data/src/images'
    end

    def default_pablo_output
      '/data/src/dist'
    end

    def default_module_file
      '/data/src/module.yaml'
    end
  end
end
