# frozen_string_literal: true

# Overall CLI app for robles
class RoblesCli < Thor
  desc 'render [PUBLISH_FILE]', 'renders book from PUBLISH_FILE. [Default: /data/src/publish.yaml]'
  options output: :string
  def render(publish_file = '/data/src/publish.yaml')
    # output = options[:output] || '/data/output'
    book = Renderer::Book.render(publish_file)
    image_extractor = ImageProvider::Extractor.new(book)
    p image_extractor.extract
  end

  desc 'publish [PUBLISH_FILE]', 'renders and publishes a book from PUBLISH_FILE. [Default: /data/src/publish.yaml]'
  def publish(publish_file = '/data/src/publish.yaml')
    book = Renderer::Book.render(publish_file)
    p Api::Alexandria::BookUploader.upload(book)
  end
end
