# frozen_string_literal: true

require_relative '../test_helper'

module Renderer
  # Characterisation tests for the plain string renderer: the path every short
  # markdown attribute (descriptions, bios, answer explanations) goes through.
  class MarkdownStringRendererTest < Minitest::Test
    include TestHelpers

    def render(content)
      MarkdownStringRenderer.new(content:).render
    end

    def test_renders_the_whole_prose_corpus
      markdown = File.read(fixture_path('markdown/prose.md'))

      assert_rendered_html('markdown/prose.string_renderer.html', render(markdown))
    end

    def test_blank_content_renders_an_empty_string
      assert_equal '', render(nil)
      assert_equal '', render('')
      assert_equal '', render("   \n")
    end

    def test_smart_punctuation_substitutions
      assert_equal %(<p>“double” ‘single’ em—dash en–dash ellipsis…</p>\n),
                   render(%q("double" 'single' em---dash en--dash ellipsis...))
    end

    def test_double_tilde_strikethrough
      assert_equal "<p><del>gone</del></p>\n", render('~~gone~~')
    end

    def test_autolink_extension
      assert_equal %(<p>See <a href="https://kodeco.com">https://kodeco.com</a>.</p>\n),
                   render('See https://kodeco.com.')
    end

    # Raw HTML is not rendered: the parser is run without the UNSAFE option, so
    # embedded markup is replaced by a comment rather than passed through.
    # Markdown reaching the string renderer comes out of YAML, and is not
    # guaranteed to arrive tagged UTF-8.
    def test_non_utf8_tagged_content_is_rendered_rather_than_rejected
      content = "H\u00e9llo \u2014 na\u00efve".dup.force_encoding(Encoding::ASCII_8BIT)

      assert_equal "<p>H\u00e9llo \u2014 na\u00efve</p>\n", render(content)
    end

    def test_raw_html_is_omitted_rather_than_passed_through
      assert_equal "<!-- raw HTML omitted -->\n", render('<script>alert(1)</script>')
      assert_equal "<p>a <!-- raw HTML omitted -->b<!-- raw HTML omitted --></p>\n", render('a <em>b</em>')
    end
  end
end
