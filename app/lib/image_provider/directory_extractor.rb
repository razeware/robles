# frozen_string_literal: true

module ImageProvider
  # Extract all images from a video course
  class DirectoryExtractor
    attr_reader :directory, :images

    def initialize(directory)
      @directory = directory
      @images = []
    end

    def extract
      @images = image_paths.map do |path|
        GalleryImage.with_representations({ local_url: path, uploaded_image_root_path: uploaded_image_root_path }, variants: ImageRepresentation::DEFAULT_WIDTHS)
      end
    end

    def uploaded_image_root_path
      'images'
    end

    def image_paths
      Dir.glob("#{directory}/**/*.png")
    end
  end
end
