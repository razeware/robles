# frozen_string_literal: true

module Runner
  # For interactive mode
  class Interactive < Runner::Base
    def default_publish_file
      '/data/src/publish.yaml'
    end
  end
end
