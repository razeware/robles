# frozen_string_literal: true

module Renderer
  # Custom implementation of a markdown renderer for RW books.
  #
  # commonmarker 2.x has no subclassable HTML renderer, so instead of overriding
  # node visitors this walks the parsed document, swaps each node it wants to
  # own for a unique placeholder, renders the document normally, and then
  # substitutes the markup it built back in. Doing it that way keeps the
  # surrounding HTML byte-for-byte what the renderer produces -- including the
  # `<p>` that ends up wrapping a `<figure>`, which is invalid HTML but is what
  # the published site has always been built with -- and it keeps author-supplied
  # raw HTML going through the renderer, which still strips it.
  class RWMarkdownRenderer
    include Renderer::ImageAttributes
    include Util::Logging

    TIMESTAMP = /\$\[t=([\d:.]+)\]/
    ANY_TIMESTAMP = /\$\[t=[\d:.]+\]/

    attr_reader :root_path

    def initialize(image_provider:, root_path:)
      logger.debug 'RWMarkdownRenderer::initialize'
      @image_provider = image_provider
      @root_path = root_path
    end

    def render(document)
      @replacements = {}
      @nonce = SecureRandom.hex(8)
      substitute(Util::Markdown.render(transform(document)))
    end

    private

    def transform(document)
      document.walk do |node|
        case node.type
        when :image then replace_image(node)
        when :text then replace_timestamps(node)
        end
      end
      document
    end

    # Swap the image node for a text node holding a placeholder. The markup is
    # emitted where the image was, so an image on its own line still renders
    # inside the paragraph that held it.
    def replace_image(node)
      return if image_provider.blank?

      node.insert_before(text_node(placeholder_for(image_html(node))))
      node.delete
    end

    # Turn `$[t=00:12.3]` into a span carrying the timestamp. Only the first
    # marker in a text node becomes a span; any others are stripped, which is
    # the behaviour the 0.x renderer had.
    def replace_timestamps(node)
      match = node.string_content.match(TIMESTAMP)
      return if match.blank?

      span = %(<span data-video-timestamp="#{match[1]}"></span>)
      node.string_content = placeholder_for(span) + node.string_content.gsub(ANY_TIMESTAMP, '')
    end

    def image_html(node)
      title = node.title.present? ? Util::Markdown.escape_html(node.title) : ''
      alt_text = node.each.select { |child| child.type == :text }.map { |child| Util::Markdown.escape_html(child.string_content) }.join(' ')

      if width_class?(alt_text) || image_provider.width_required == false
        figure_html(node, title, class_list(alt_text), alt_text)
      else
        missing_width_html(node)
      end
    end

    def figure_html(node, title, classes, alt_text)
      [
        %(<figure title="#{title}" class="#{classes}">),
        '  <picture>',
        picture_html(node, title, alt_text),
        '  </picture>',
        "  <figcaption>#{title}</figcaption>",
        '</figure>'
      ].join
    end

    def picture_html(node, title, alt_text)
      return svg_content(node.url) if svg?(alt_text, node.url)

      image_srcset = srcset(node.url)
      img = %(    <img src="#{src(node.url)}" alt="#{title}" title="#{title}">)
      # GIFs (and any image without generated variants) only have the original,
      # so skip the empty <source> rather than emit a broken one.
      image_srcset.present? ? "#{img}    <source srcset=\"#{image_srcset}\">" : img
    end

    def missing_width_html(node)
      [
        '<blockquote>',
        '  <h3 style="color: red; margin-top: 0;">Error: This image is missing a width attribute</h3>',
        %(  <p style="color: red;">Please provide one in the form of <code>![width=50%](#{node.url})</code></p>),
        '  <p style="color: red;">The image has been hidden until this issue is resolved.</p>',
        '</blockquote>'
      ].join
    end

    def text_node(content)
      Commonmarker::Node.new(:text).tap { |node| node.string_content = content }
    end

    # Alphanumeric so that neither smart punctuation, autolinking nor HTML
    # escaping can touch it on the way through the renderer, and salted so it
    # cannot collide with anything an author wrote.
    def placeholder_for(html)
      "rwmd#{@nonce}x#{@replacements.length}x".tap { |token| @replacements[token] = html }
    end

    def substitute(html)
      return html if @replacements.empty?

      html.gsub(/rwmd#{@nonce}x\d+x/) { |token| @replacements.fetch(token) }
    end
  end
end
