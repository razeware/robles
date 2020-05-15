# frozen_string_literal: true

module ImageProvider
  # Extract all images from a book
  class Extractor
    # Process markdown, and extract a list of images
    class MarkdownRenderer < Redcarpet::Render::Base
      attr_reader :images

      def initialize
        super
        @images = []
      end

      def image(link, _title, _alt_text)
        p link
        p images
        #images.push(link)
      end
    end

    attr_reader :book, :images

    def initialize(book)
      @book = book
      @images = []
    end

    def extract
      book.sections.each do |section|
        images << extract_images_from_markdown(section.markdown_file)
        section.chapters.each do |chapter|
          images << extract_images_from_markdown(chapter.markdown_file)
        end
      end
      images
    end

    def extract_images_from_markdown(file)
      renderer = MarkdownRenderer.new
      raw_markdown = File.read(file)
      rc = Redcarpet::Markdown.new(renderer)
      rc.render(raw_markdown)
      renderer.images
    end
  end
end
