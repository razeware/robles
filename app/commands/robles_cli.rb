# frozen_string_literal: true

# Overall CLI app for robles
class RoblesCli < Thor
  desc 'render [PUBLISH_FILE]', 'renders book from PUBLISH_FILE. [Default: /data/src/publish.yaml]'
  option :local, type: :boolean
  def render(publish_file = '/data/src/publish.yaml')
    parser = Parser::Publish.new(file: publish_file)
    book = parser.parse
    image_provider = options[:local] ? nil : ImageProvider::Provider.new(book: book)
    image_provider&.process
    renderer = Renderer::Book.new(book: book, image_provider: image_provider)
    renderer.render
    p book.sections.first.chapters.last
  end

  desc 'publish [PUBLISH_FILE]', 'renders and publishes a book from PUBLISH_FILE. [Default: /data/src/publish.yaml]'
  def publish(publish_file = '/data/src/publish.yaml')
    parser = Parser::Publish.new(file: publish_file)
    book = parser.parse
    image_provider = ImageProvider::Provider.new(book: book)
    image_provider.process
    renderer = Renderer::Book.new(book: book, image_provider: image_provider)
    renderer.render
    Api::Alexandria::BookUploader.upload(book)
  end

  desc 'lint [PUBLISH_FILE]', 'runs a selection of linters on the book specified by PUBLISH_FILE. [Default: /data/src/publish.yaml]'
  method_options 'without-edition': :boolean, aliases: '-e', default: false, desc: 'Run linting without git branch naming check'
  method_options silent: :boolean, aliases: '-s', default: false, desc: 'Hide all output'
  def lint(publish_file = '/data/src/publish.yaml')
    p ENV
    CLI::UI::StdoutRouter.enable unless options['silent']

    linter = Linting::Linter.new(file: publish_file)
    output = linter.lint(options: options)
    Cli::OutputFormatter.render(output) unless options['silent']
  end
end
