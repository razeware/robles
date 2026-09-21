# frozen_string_literal: true

# Boot the full robles environment (Bundler + Zeitwerk autoloading) so tests can
# exercise the real classes against their real dependencies.
require_relative '../config/application'

require 'minitest/autorun'

module TestHelpers
  def fixture_path(name)
    File.expand_path(File.join('fixtures', name), __dir__)
  end

  # Characterisation assertion: compares rendered HTML byte-for-byte against a
  # committed fixture. These fixtures were captured from the markdown renderer
  # the published site is built with, so any difference is a change in output
  # that needs a decision, not a fixture refresh.
  def assert_rendered_html(fixture_name, actual)
    expected = File.read(fixture_path(fixture_name))

    assert_equal expected, actual, "Rendered HTML differs from the characterisation fixture #{fixture_name}"
  end
end
