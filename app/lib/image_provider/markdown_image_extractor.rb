# frozen_string_literal: true

module ImageProvider
  # Takes a markdown file, and returns all the images URLs
  class MarkdownImageExtractor
    # Process markdown, and extract a list of images
    class MarkdownRenderer < Redcarpet::Render::Base
      attr_reader :images

      def initialize
        super
        @images = []
      end

      def reset
        @images = []
      end

      def image(link, _title, _alt_text)
        images << link
        nil
      end
    end

    include Util::PathExtraction

    def self.images_from(file)
      new(file: file).images
    end

    def images
      md_renderer.reset
      renderer.render(markdown)
      md_renderer.images.map { |path| apply_path(path) }
    end

    def renderer
      @renderer ||= Redcarpet::Markdown.new(md_renderer)
    end

    def md_renderer
      @md_renderer ||= MarkdownRenderer.new
    end

    def markdown
      @markdown ||= File.read(file)
    end
  end
end
