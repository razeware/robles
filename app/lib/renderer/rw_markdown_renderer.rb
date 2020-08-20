# frozen_string_literal: true

module Renderer
  # Custom implementation of a markdown renderer for RW books
  class RWMarkdownRenderer < CommonMarker::HtmlRenderer
    include Renderer::ImageAttributes
    include Util::Logging

    attr_reader :root_path

    def initialize(options: :DEFAULT, extensions: [], image_provider:, root_path:)
      logger.debug 'RWMarkdownRenderer::initialize'
      super(options: options, extensions: extensions)
      @image_provider = image_provider
      @root_path = root_path
    end

    def image(node)
      return super(node) if image_provider.blank?

      title = node.title.present? ? escape_html(node.title) : ''
      classes = class_list(node.each.select { |child| child.type == :text }.map { |child| escape_html(child.string_content) }.join(' '))

      out('<figure title="', title, '"', ' class="', classes, '">')
      out('  <picture>')
      out('    <img src="', src(node.url), '" alt="', title, '" title="', title, '">')
      out('    <source srcset="', srcset(node.url), '">')
      out('  </picture>')
      out('  <figcaption>', title, '</figcaption>')
      out('</figure>')
    end
  end
end
