# frozen_string_literal: true

# An implementation of an image provider suitable for use in the server
class LocalImageProvider
  attr_reader :chapter

  def initialize(chapter:)
    @chapter = chapter
  end

  def process
    image_paths = extract_images_from_markdown(chapter.markdown_file)
    @images = extract(image_paths)
  end

  def representations_for_local_url(url)
    clean_url = Pathname.new(url).cleanpath.to_s
    @images
      .find { |image| image.local_url == clean_url }
      &.representations
  end

  def extract(image_paths)
    image_paths.map do |path|
      Image.with_original_representation(local_url: path[:absolute_path])
    end
  end

  def extract_images_from_markdown(file)
    ImageProvider::MarkdownImageExtractor.images_from(file)
  end
end
