source 'https://rubygems.org'

git_source(:github) { |repo_name| "https://github.com/#{repo_name}" }

# Stealing some bits from rails
gem 'activemodel', '~> 6.0', '>= 6.0.3'
gem 'activesupport', '~> 6.0', '>= 6.0.3'
# Autoloading explictly will use zeitwerk
gem 'zeitwerk', '~> 2.3'

# Building a CLI
gem 'cli-ui', '~> 1.3'
gem 'thor', '~> 1.0', '>= 1.0.1'

# Markdown processing
gem 'redcarpet', '~> 3.5'

group :development do
  # For integration with VSCode
  gem 'debase', '~> 0.2.4.1'
  gem 'rubocop', '~> 0.81'
  gem 'ruby-debug-ide', '~> 0.7.2'
  gem 'solargraph', '~> 0.39'
end
