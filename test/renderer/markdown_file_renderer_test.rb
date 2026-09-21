# frozen_string_literal: true

require 'tmpdir'
require_relative '../test_helper'

module Renderer
  # Characterisation tests for the file renderer: the path every chapter,
  # section and lesson body goes through on its way to the published site.
  class MarkdownFileRendererTest < Minitest::Test
    include TestHelpers

    def render_fixture(name, **)
      MarkdownFileRenderer.new(path: fixture_path("markdown/#{name}"), **).render
    end

    def render_string(markdown, **options)
      Dir.mktmpdir do |dir|
        path = File.join(dir, 'body.md')
        File.write(path, markdown)
        MarkdownFileRenderer.new(path:, **options).render
      end
    end

    def test_renders_the_whole_prose_corpus
      assert_rendered_html('markdown/prose.file_renderer.html', render_fixture('prose.md'))
    end

    def test_video_timestamp_markers_become_spans
      assert_rendered_html('markdown/timestamps.file_renderer.html', render_fixture('timestamps.md'))
    end

    # Timestamps assigned from a real WebVTT transcript. Which cue each
    # paragraph matches depends on the plain-text extraction the matcher runs
    # on, so pinning the exact markers pins that extraction too.
    def test_transcript_timestamps_are_matched_to_paragraphs
      html = render_fixture('spoken.md', vtt_file: fixture_path('transcript.vtt'))

      assert_rendered_html('markdown/spoken.file_renderer.html', html)
    end

    def test_the_leading_h1_is_removed
      assert_equal "<p>Body copy.</p>\n", render_string("# Chapter Title\n\nBody copy.\n")
    end

    def test_deeper_headings_are_kept
      assert_equal "<h2>Kept</h2>\n<p>Body.</p>\n", render_string("## Kept\n\nBody.\n")
    end

    def test_metadata_frontmatter_is_stripped
      markdown = "```metadata\ntitle: Ignored\n```\n\nBody copy.\n"

      assert_equal "<p>Body copy.</p>\n", render_string(markdown)
    end

    def test_comment_lines_are_stripped
      markdown = "Kept line.\n\n$[//] this whole line goes away\n\nAlso kept.\n"

      assert_equal "<p>Kept line.</p>\n<p>Also kept.</p>\n", render_string(markdown)
    end

    def test_pagesetting_notation_is_stripped
      assert_equal "<p>Before after.</p>\n", render_string("Before $[=s=]after.\n")
      assert_equal "<p>Before after.</p>\n", render_string("Before $[=p=]after.\n")
      assert_equal "<p>Before after.</p>\n", render_string("Before $[===]after.\n")
    end

    # commonmarker 2.x refuses anything not tagged UTF-8, and markdown read off
    # disk otherwise picks up whatever the process's default external encoding
    # happens to be.
    def test_non_ascii_markdown_renders_whatever_the_default_external_encoding_is
      Dir.mktmpdir do |dir|
        path = File.join(dir, 'body.md')
        File.write(path, "H\u00e9llo \u2014 na\u00efve \u201cquotes\u201d\n", mode: 'w:UTF-8')

        assert_equal "<p>H\u00e9llo \u2014 na\u00efve \u201cquotes\u201d</p>\n",
                     MarkdownFileRenderer.new(path:).render
      end
    end

    def test_team_bio_markers_become_a_div
      markdown = "$[#tb]\n\nA bio paragraph.\n\n$[tb#]\n"

      assert_equal "<div>\n<p>A bio paragraph.</p>\n</div>\n", render_string(markdown)
    end
  end
end
