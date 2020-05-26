# frozen_string_literal: true

module Runner
  # Base class with shared functionality
  class Base
    include Util::Logging

    def self.runner
      return Runner::Ci.new if CI

      Runner::Interactive.new
    end

    def initialize
      logger.debug("ENV: #{ENV.to_hash}")
      logger.info("Creating runner with default publish file: #{default_publish_file}")
      logger.debug(Dir[Pathname.new(default_publish_file).dirname + '*'])
    end

    def render(publish_file:, local: false)
      publish_file ||= default_publish_file

      parser = Parser::Publish.new(file: publish_file)
      book = parser.parse
      image_provider = local ? nil : ImageProvider::Provider.new(book: book)
      image_provider&.process
      renderer = Renderer::Book.new(book: book, image_provider: image_provider)
      renderer.render
      book
    end

    def publish(publish_file:)
      publish_file ||= default_publish_file

      parser = Parser::Publish.new(file: publish_file)
      book = parser.parse
      image_provider = ImageProvider::Provider.new(book: book)
      image_provider.process
      renderer = Renderer::Book.new(book: book, image_provider: image_provider)
      renderer.render
      Api::Alexandria::BookUploader.upload(book)
    end

    def lint(publish_file:, options: {})
      publish_file ||= default_publish_file
      logger.info("Attempting to lint using publish file at #{publish_file}")

      CLI::UI::StdoutRouter.enable unless options['silent']

      linter = Linting::Linter.new(file: publish_file)
      output = linter.lint(options: options)
      Cli::OutputFormatter.render(output) unless options['silent']
      output
    end

    def default_publish_file
      raise 'Override this in a subclass please'
    end
  end
end
