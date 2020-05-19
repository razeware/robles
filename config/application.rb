# frozen_string_literal: true

require_relative 'boot'

# Require the gems listed in Gemfile
Bundler.require(:default)
require 'active_support/all'
require 'active_model'

# Load the initialisers
Dir[File.join(__dir__, 'initialisers', '*.rb')].sort.each { |file| require file }

# Configure the autoloader
@loader = Zeitwerk::Loader.new
@loader.push_dir(File.expand_path('../app/commands', __dir__))
@loader.push_dir(File.expand_path('../app/lib', __dir__))
@loader.push_dir(File.expand_path('../app/models', __dir__))
@loader.collapse('**/concerns')
@loader.enable_reloading if ENV['ENV'] == 'development'
@loader.setup # ready!

# Create a logger
@logger = ActiveSupport::Logger.new(STDOUT)

def reload!
  @loader.reload if ENV['ENV'] == 'development'
end
