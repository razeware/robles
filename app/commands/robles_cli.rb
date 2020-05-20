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
    p Api::Alexandria::BookUploader.upload(book)
  end
end
