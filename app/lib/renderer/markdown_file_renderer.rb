# frozen_string_literal: true

module Renderer
  # Read a file and render the markdown
  class MarkdownFileRenderer
    include Util::Logging
    include Parser::FrontmatterMetadataFinder

    attr_reader :path, :image_provider, :vtt_file

    def initialize(path:, image_provider: nil, vtt_file: nil)
      @path = path
      @image_provider = image_provider
      @vtt_file = vtt_file
    end

    def render
      logger.debug 'MarkdownFileRenderer::render'
      remove_h1(doc)
      apply_vtt_timestamps(doc)
      fix_team_bio_markup(rw_renderer.render(doc))
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

    def apply_vtt_timestamps(document)
      return unless vtt_file.present?

      timestamper = MarkdownTimestamper.new(document, vtt_file)
      timestamper.apply!
    end

    def fix_team_bio_markup(html)
      # It'd be nice to do this pre-render, but that involves allowing unsafe rendering of HTML
      html.gsub(/<p>\$\[#tb\]<\/p>/, '<div>').gsub(/<p>\$\[tb#\]<\/p>/, '</div>')
    end

    def root_directory
      @root_directory ||= Pathname.new(path).dirname
    end
  end
end
