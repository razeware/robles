# frozen_string_literal: true

# Overall CLI app for robles
class RoblesCli < Thor
  desc 'render', 'renders book'
  option :'publish-file', type: :string, desc: 'Location of the publish.yaml file'
  option :local, type: :boolean
  def render
    book = runner.render(publish_file: options['publish_file'], local: options['local'])
    p book.sections.first.chapters.last
  end

  desc 'publish [PUBLISH_FILE]', 'renders and publishes a book'
  option :'publish-file', type: :string, desc: 'Location of the publish.yaml file'
  def publish
    runner.publish(publish_file: options['publish_file'])
  end

  desc 'lint [PUBLISH_FILE]', 'runs a selection of linters on the book'
  option :'publish-file', type: :string, desc: 'Location of the publish.yaml file'
  method_options 'without-edition': :boolean, aliases: '-e', default: false, desc: 'Run linting without git branch naming check'
  method_options silent: :boolean, aliases: '-s', default: false, desc: 'Hide all output'
  def lint
    runner.lint(publish_file: options['publish_file'], options: options)
  end

  private

  def runner
    Runner::Base.runner
  end
end
