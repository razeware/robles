# frozen_string_literal: true

module Renderer
  # Read a file and render the markdown
  class MarkdownFileRenderer
    include Util::Logging
    include Parser::FrontmatterMetadataFinder

    attr_reader :path
    attr_reader :image_provider

    def initialize(path:, image_provider: nil)
      @path = path
      @image_provider = image_provider
    end

    def render
      logger.debug 'MarkdownFileRenderer::render'
      remove_h1(doc)
      rw_renderer.render(doc)
    end

    def rw_renderer
      @rw_renderer ||= Renderer::RWMarkdownRenderer.new(
        options: %i[TABLE_PREFER_STYLE_ATTRIBUTES],
        extensions: %i[table strikethrough autolink],
        image_provider: image_provider,
        root_path: root_directory
      )
    end

    def raw_content
      @raw_content ||= File.read(path)
    end

    def preproccessed_markdown
      @preproccessed_markdown ||= begin
        removing_pagesetting_notation = raw_content.gsub(/\$\[=[=sp]=\]/, '')
        without_metadata(removing_pagesetting_notation.each_line)
      end
    end

    def doc
      @doc ||= CommonMarker.render_doc(
        preproccessed_markdown,
        %i[SMART STRIKETHROUGH_DOUBLE_TILDE],
        %i[table strikethrough autolink]
      )
    end

    def remove_h1(document)
      document.walk do |node|
        node.delete if node.type == :header && node.header_level.to_i == 1
      end
      document
    end

    def root_directory
      @root_directory ||= Pathname.new(path).dirname
    end
  end
end
