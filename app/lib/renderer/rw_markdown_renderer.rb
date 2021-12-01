# frozen_string_literal: true

module Renderer
  # Custom implementation of a markdown renderer for RW books
  class RWMarkdownRenderer < CommonMarker::HtmlRenderer
    include Renderer::ImageAttributes
    include Util::Logging

    attr_reader :root_path

    def initialize(image_provider:, root_path:, options: :DEFAULT, extensions: [])
      logger.debug 'RWMarkdownRenderer::initialize'
      super(options: options, extensions: extensions)
      @image_provider = image_provider
      @root_path = root_path
    end

    def image(node) # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
      return super(node) if image_provider.blank?

      title = node.title.present? ? escape_html(node.title) : ''
      alt_text = node.each.select { |child| child.type == :text }.map { |child| escape_html(child.string_content) }.join(' ')
      classes = class_list(alt_text)

      if !has_width_class?(alt_text)
        out('<blockquote>')
          out('  <h3 style="color: red; margin-top: 0;">Error: This image is missing a width attribute</h3>')
          out('  <p style="color: red;">Please provide one in the form of <code>![width=50%](', node.url, ')</code></p>')
          out('  <p style="color: red;">The image has been hidden until this issue is resolved.</p>')
        out('</blockquote>')
      else
        out('<figure title="', title, '"', ' class="', classes, '">')
        out('  <picture>')
        if svg?(alt_text, node.url)
          out(svg_content(node.url))
        else
          out('    <img src="', src(node.url), '" alt="', title, '" title="', title, '">')
          out('    <source srcset="', srcset(node.url), '">')
        end
        out('  </picture>')
        out('  <figcaption>', title, '</figcaption>')
        out('</figure>')
      end
    end

    def text(node)
      # If no timestamp, just move on
      return super(node) unless node.string_content.match?(/\$\[t=[\d:.]+\]/)

      # Find the timestamp and turn it into a data tag on a span
      timestamp = node.string_content.match(/\$\[t=([\d:.]+)\]/)[1]
      out("<span data-video-timestamp=\"#{timestamp}\"></span>")

      out(escape_html(node.string_content.gsub(/\$\[t=[\d:.]+\]/, '')))
    end
  end
end
