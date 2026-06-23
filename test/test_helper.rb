# frozen_string_literal: true

# Boot the full robles environment (Bundler + Zeitwerk autoloading) so tests can
# exercise the real classes against their real dependencies.
require_relative '../config/application'

require 'minitest/autorun'

module TestHelpers
  def fixture_path(name)
    File.expand_path(File.join('fixtures', name), __dir__)
  end
end
