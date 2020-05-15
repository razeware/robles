# frozen_string_literal: true

module ImageProvider
  # Extract all images from a book
  class Extractor
    attr_reader :book, :images

    def initialize(book)
      @book = book
      @images = []
    end

    def extract
      book.sections.each do |section|
        @images << extract_images_from_markdown(section.markdown_file)
        section.chapters.each do |chapter|
          @images << extract_images_from_markdown(chapter.markdown_file)
        end
      end
      @images = @images.flatten.compact.uniq
    end

    def extract_images_from_markdown(file)
      MarkdownImageExtractor.images_from(file)
    end
  end
end
