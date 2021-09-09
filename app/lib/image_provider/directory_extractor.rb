# frozen_string_literal: true

module ImageProvider
  # Extract all images from a directory
  class DirectoryExtractor
    attr_reader :directory, :images

    def initialize(directory)
      @directory = directory
      @images = []
    end

    def extract
      @images = image_paths.map do |path|
        GalleryImage.with_representations(
          { local_url: path, uploaded_image_root_path: uploaded_image_root_path },
          representation_attributes: { include_source_filename: true })
      end
    end

    def uploaded_image_root_path
      'pablo'
    end

    def image_paths
      Dir.glob("#{directory}/**/*.png")
    end
  end
end
