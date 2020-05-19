# frozen_string_literal: true

require_relative 'boot'

# Require the gems listed in Gemfile
Bundler.require(:default)
require 'active_support/all'
require 'active_model'
require 'psych'

# Load the initialisers
Dir[File.join(__dir__, 'initialisers', '*.rb')].sort.each { |file| require file }

# Configure the autoloader
@loader = Zeitwerk::Loader.new

# Autoloaded root paths
@loader.push_dir(File.expand_path('../app/commands', __dir__))
@loader.push_dir(File.expand_path('../app/lib', __dir__))
@loader.push_dir(File.expand_path('../app/models', __dir__))

# All *concerns* subdirectories are collapsed (i.e. models/concerns/uploadable => Uploadable, not Concerns::Uploadable)
@loader.collapse('**/concerns')

# Custom inflections
@loader.inflector.inflect(
  'rw_markdown_renderer' => 'RWMarkdownRenderer'
)

# We'll allow reloading in development mode
@loader.enable_reloading if ENV['ENV'] == 'development'

# Complete autoloader configuration
@loader.setup

def reload!
  @loader.reload if ENV['ENV'] == 'development'
end
