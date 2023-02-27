# frozen_string_literal: true

module ImageProvider
  # Extract all images from a directory
  class DirectoryExtractor
    attr_reader :directory, :images, :local_server

    def initialize(directory, local_server: false)
      @directory = directory
      @local_server = local_server
      @images = []
    end

    def extract
      return self if images.present?

      @images = image_paths.map do |path|
        GalleryImage.with_representations(
          {
            directory:,
            local_url: path,
            uploaded_image_root_path:
          },
          representation_attributes: {
            include_source_filename: true,
            local_server:
          }
        )
      end
      self
    end

    def categories
      images.map(&:category)&.uniq&.compact_blank || []
    end

    def uploaded_image_root_path
      'pablo'
    end

    def image_paths
      Dir.glob("#{directory}/**/*.png")
    end
  end
end
