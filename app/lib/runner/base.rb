# frozen_string_literal: true

module Runner
  # Base class with shared functionality
  class Base
    include Util::Logging
    include Util::SlackNotifiable

    def self.runner
      return Runner::Ci.new if CI

      Runner::Interactive.new
    end

    # For books
    def render_book(publish_file:, local: false)
      publish_file ||= default_publish_file

      parser = Parser::Publish.new(file: publish_file)
      book = parser.parse
      image_extractor = ImageProvider::BookExtractor.new(book)
      image_provider = local ? nil : ImageProvider::Provider.new(extractor: image_extractor)
      image_provider&.process
      renderer = Renderer::Book.new(book, image_provider:)
      renderer.render
      book
    end

    def publish_book(publish_file:)
      publish_file ||= default_publish_file
      parser = Parser::Publish.new(file: publish_file)
      book = parser.parse
      image_extractor = ImageProvider::BookExtractor.new(book)
      image_provider = ImageProvider::Provider.new(extractor: image_extractor)
      image_provider.process
      Renderer::Book.new(book, image_provider:).render
      Api::Alexandria::BookUploader.upload(book)
      notify_book_success(book:)
    rescue StandardError => e
      notify_book_failure(book: defined?(book) ? book : nil, details: e.full_message)
      raise e
    end

    def lint_book(publish_file:, options: {})
      publish_file ||= default_publish_file
      logger.info("Attempting to lint using publish file at #{publish_file}")

      CLI::UI::StdoutRouter.enable unless options['silent']

      linter = Linting::BookLinter.new(file: publish_file)
      output = linter.lint(options:)
      Cli::OutputFormatter.render(output) unless options['silent']
      output
    end

    # For video courses
    def render_video_course(release_file:, local: false)
      release_file ||= default_release_file

      parser = Parser::Release.new(file: release_file)
      video_course = parser.parse
      image_extractor = ImageProvider::VideoCourseExtractor.new(video_course)
      image_provider = local ? nil : ImageProvider::Provider.new(extractor: image_extractor)
      image_provider&.process
      renderer = Renderer::VideoCourse.new(video_course, image_provider:)
      renderer.render
      video_course
    end

    def upload_video_course(release_file:)
      release_file ||= default_release_file

      parser = Parser::Release.new(file: release_file)
      video_course = parser.parse

      image_extractor = ImageProvider::VideoCourseExtractor.new(video_course)
      image_provider = ImageProvider::Provider.new(extractor: image_extractor)
      image_provider.process
      Renderer::VideoCourse.new(video_course, image_provider:).render
      Api::Betamax::VideoCourseUploader.upload(video_course)
      notify_video_course_success(video_course:)
    rescue StandardError => e
      notify_video_course_failure(video_course: defined?(video_course) ? video_course : nil, details: e.full_message)
      raise e
    end

    def lint_video_course(release_file:, options: {})
      release_file ||= default_release_file
      logger.info("Attempting to lint using release file at #{release_file}")

      CLI::UI::StdoutRouter.enable unless options['silent']

      linter = Linting::VideoCourseLinter.new(file: release_file)
      output = linter.lint(options:)
      Cli::OutputFormatter.render(output) unless options['silent']
      output
    end

    # pablo
    def serve_pable(source:)
      source ||= default_pablo_source

      extractor = ImageProvider::DirectoryExtractor.new(
        source,
        local_server: true
      )
      RoblesPabloServer.run!(image_extractor: extractor)
    end

    def publish_pablo(source:, output:)
      source ||= default_pablo_source
      output ||= default_pablo_output

      image_extractor = ImageProvider::DirectoryExtractor.new(source)
      image_provider = ImageProvider::Provider.new(extractor: image_extractor)
      image_provider.process

      paths = image_extractor.categories.map { "/#{_1}" }.push('/', '/license', '/instructions', '/styles.css', '/javascript/search.js')

      ENV['DISABLE_LIVERELOAD'] = 'true'
      RoblesPabloServer.save!(paths:, destination: output, options: {
                                image_extractor:
                              })
    end

    def default_publish_file
      raise 'Override this in a subclass please'
    end

    def default_release_file
      raise 'Override this in a subclass please'
    end

    def default_pablo_source
      raise 'Override this in a subclass please'
    end

    def default_pablo_output
      raise 'Override this in a subclass please'
    end
  end
end
