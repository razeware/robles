source 'https://rubygems.org'

git_source(:github) { |repo_name| "https://github.com/#{repo_name}" }

# Stealing some bits from rails
gem 'activemodel', '~> 6.0'
gem 'activesupport', '~> 6.0'
# Autoloading explictly will use zeitwerk
gem 'zeitwerk', '~> 2.3'

# Building a CLI
gem 'cli-ui', '~> 1.3'
gem 'thor', '~> 1.0', '>= 1.0.1'

# Markdown processing
gem 'commonmarker'

# HTTP Client
gem 'faraday'

# Git Client
gem 'git'

# Image processing
gem 'mini_magick'

# AWS Access
gem 'aws-sdk-s3', '~> 1.64'

# For multithreading image proceesing
gem 'concurrent-ruby', '~> 1.1'

# Interacting with github
gem 'octokit', '~> 4.19'

# Interface with libsodium
gem 'rbnacl'

# Sending notifications to slack
gem 'slack-notifier', '~> 2.3', '>= 2.3.2'

# Local previewing
gem 'sassc'
gem 'sinatra', '~> 2', '>= 2.0.8.1'

# Controlling Chrome to create snapshots
gem 'ferrum'

group :development do
  # For integration with VSCode
  gem 'debase', '~> 0.2.4.1'
  gem 'rubocop', '~> 0.81'
  gem 'ruby-debug-ide', '~> 0.7.2'
  gem 'solargraph', '~> 0.39'

  # Auto-reloading when serving locally
  gem 'guard', '~> 2', '>= 2.16.2'
  gem 'guard-livereload', '~> 2.5', require: false
  gem 'rack-livereload'
end
