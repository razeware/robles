# frozen_string_literal: true

module ImageProvider
  # Extract all images from a content module
  class ContentModuleExtractor
    attr_reader :content_module, :images

    def initialize(content_module)
      @content_module = content_module
      @images = []
    end

    def extract
      @images = image_paths.map do |path|
        Image.with_representations({ local_url: path[:absolute_path], uploaded_image_root_path: }, variants: path[:variants])
      end
    end

    def extract_images_from_markdown(file)
      MarkdownImageExtractor.images_from(file) if file && File.exist?(file)
    end

    def uploaded_image_root_path
      "content_module/#{Digest::SHA2.hexdigest(content_module.shortcode)}/images"
    end

    def image_paths
      content_module.lessons.map do |lesson|
        from_segments = lesson.segments.map do |segment|
          next unless segment.respond_to?(:markdown_file)

          extract_images_from_markdown(segment.markdown_file) + segment.image_attachment_paths
        end

        from_segments + lesson.image_attachment_paths
      end.flatten.compact.uniq + content_module.image_attachment_paths
    end
  end
end
