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
      @images = image_paths.map do |path|
        Image.with_representations(local_url: path[:absolute_path], sku: book.sku)
      end
    end

    def extract_images_from_markdown(file)
      MarkdownImageExtractor.images_from(file)
    end

    def image_paths # rubocop:disable Metrics/AbcSize
      book.sections.map do |section|
        from_chapters = section.chapters.map do |chapter|
          extract_images_from_markdown(chapter.markdown_file) + chapter.image_attachment_paths
        end

        from_chapters + extract_images_from_markdown(section.markdown_file) + section.image_attachment_paths
      end.flatten.compact.uniq + book.image_attachment_paths
    end
  end
end
