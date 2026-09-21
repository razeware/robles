# frozen_string_literal: true

module Util
  # The single place robles talks to commonmarker.
  #
  # commonmarker 2.x wraps comrak, whose defaults differ from the cmark-gfm
  # defaults robles was written against, so every option that would change the
  # published HTML is pinned here rather than left to the library:
  #
  # - `hardbreaks` defaults to true in 2.x, which turns every soft line break
  #   into a `<br />`. Book markdown is hard-wrapped, so that would insert a
  #   line break in the middle of most paragraphs.
  # - `github_pre_lang` defaults to true, which emits `<pre lang="swift">`
  #   instead of the `<code class="language-swift">` the site's syntax
  #   highlighting keys off.
  # - `escaped_char_spans` defaults to true, wrapping backslash-escaped
  #   characters in a `<span data-escaped-char>`.
  # - 2.x turns the tasklist, shortcodes, tagfilter and header_ids extensions on
  #   by default. robles has only ever enabled table, strikethrough and
  #   autolink, and header_ids would append an anchor link to every heading.
  # - the default `syntax_highlighter` plugin inlines syntect styles into every
  #   code block. Highlighting is the front end's job, so it is switched off.
  module Markdown
    # Parsing and rendering for content that ends up on the site.
    CONTENT_OPTIONS = {
      parse: { smart: true },
      render: { hardbreaks: false, github_pre_lang: false, escaped_char_spans: false, unsafe: false },
      extension: {
        strikethrough: true, table: true, autolink: true,
        tagfilter: false, tasklist: false, shortcodes: false, header_ids: nil
      }
    }.freeze

    # Plain CommonMark with no extensions, for the passes that only inspect the
    # document (word counting, image extraction) rather than render it.
    PLAIN_OPTIONS = {
      parse: { smart: false },
      render: { hardbreaks: false, github_pre_lang: false, escaped_char_spans: false, unsafe: false },
      extension: {
        strikethrough: false, table: false, autolink: false,
        tagfilter: false, tasklist: false, shortcodes: false, header_ids: nil
      }
    }.freeze

    PLUGINS = { syntax_highlighter: nil }.freeze

    # cmark-gfm escapes exactly these four characters in HTML output, and the
    # markup robles builds by hand has to match what the renderer does.
    HTML_ESCAPES = { '&' => '&amp;', '<' => '&lt;', '>' => '&gt;', '"' => '&quot;' }.freeze

    # Nodes that carry the text a human reads.
    TEXT_NODES = %i[text code].freeze
    BREAK_NODES = %i[softbreak linebreak].freeze

    module_function

    def parse(markdown, options: CONTENT_OPTIONS)
      Commonmarker.parse(utf8(markdown), options:)
    end

    def to_html(markdown, options: CONTENT_OPTIONS)
      Commonmarker.to_html(utf8(markdown), options:, plugins: PLUGINS)
    end

    def render(document, options: CONTENT_OPTIONS)
      document.to_html(options:, plugins: PLUGINS)
    end

    # commonmarker 2.x rejects anything that is not tagged UTF-8, where 0.x
    # accepted whatever it was handed. Markdown read off disk picks up the
    # process's default external encoding, which is not UTF-8 everywhere robles
    # runs, so re-tag rather than let the renderer raise.
    def utf8(string)
      string = string.to_s
      string.encoding == Encoding::UTF_8 ? string : string.dup.force_encoding(Encoding::UTF_8)
    end

    def escape_html(text)
      text.to_s.gsub(/[&<>"]/) { |char| HTML_ESCAPES[char] }
    end

    # Stands in for 0.x's Node#to_plaintext, which 2.x does not provide: the
    # readable text of a node, with soft and hard line breaks kept as newlines
    # so words either side of one do not run together.
    def plaintext(node)
      (+'').tap do |text|
        node.walk do |child|
          text << child.string_content if TEXT_NODES.include?(child.type)
          text << "\n" if BREAK_NODES.include?(child.type)
        end
      end
    end
  end
end
