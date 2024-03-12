source 'https://rubygems.org'

git_source(:github) { |repo_name| "https://github.com/#{repo_name}" }

# Stealing some bits from rails
gem 'activemodel', '< 7.2'
gem 'activesupport', '< 7.2'
# Autoloading explictly will use zeitwerk
gem 'zeitwerk', '~> 2.3'

# Building a CLI
gem 'cli-ui', '~> 2'
gem 'thor', '~> 1.0', '>= 1.0.1'

# Markdown processing
# >= 1 switches out the underlying library to one that does not support musl
# Currently, there are no plans to support it, so let's lock to < 1
gem 'commonmarker', '< 1'

# HTTP Client
gem 'faraday', '~> 2'
gem 'faraday-retry'

# Git Client
gem 'git'

# Image processing
gem 'mini_magick'

# AWS Access
gem 'aws-sdk-s3', '~> 1.64'

# For multithreading image proceesing
gem 'concurrent-ruby', '~> 1.1'

# Interacting with github
gem 'octokit', '~> 8'

# Interface with libsodium
gem 'rbnacl'

# Sending notifications to slack
gem 'slack-notifier', '~> 2.3', '>= 2.3.2'

# Local previewing
gem 'rackup'
gem 'sass-embedded'
gem 'sinatra', '~> 4'
gem 'thin'

# Pinning google-protobuf so that it continues to build on ARM devices
gem 'google-protobuf', '=3.22.0'

# Controlling Chrome to create snapshots
gem 'ferrum'

# Saving pablo as a static site
gem 'rack-test'

# Creating transcripts
# Note: This is waiting for support for bundler 3.4 and ruby 3.2 on upstream.
# https://github.com/dbalatero/levenshtein-ffi/pull/12
gem 'levenshtein-ffi', require: 'levenshtein', git: 'https://github.com/razeware/levenshtein-ffi.git'
# NOTE: This is waiting for 3.2 support on upstream.
# https://github.com/opencoconut/webvtt-ruby/pull/20
gem 'webvtt-ruby', require: 'webvtt', git: 'https://github.com/razeware/webvtt-ruby.git'

group :development do
  # For integration with VSCode
  gem 'rubocop', '~> 1.0'
  gem 'solargraph', '~> 0.39'

  # Auto-reloading when serving locally
  gem 'guard', '~> 2', '>= 2.16.2'
  gem 'guard-livereload'
  gem 'rack-livereload'
end
