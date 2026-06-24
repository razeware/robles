# frozen_string_literal: true

require_relative '../test_helper'

module Renderer
  # Exercises the real timestamper against a real WebVTT fixture (no stubbing).
  # The fixture only needs to contain a few cues — the Levenshtein matcher will
  # assign *some* timestamp to every paragraph we don't deliberately skip, so the
  # assertions here are about which nodes get a `$[t=...]` marker, not which one.
  class MarkdownTimestamperTest < Minitest::Test
    include TestHelpers

    TIMESTAMP = /\$\[t=[\d:.]+\]/

    def render(markdown)
      doc = CommonMarker.render_doc(markdown, %i[SMART], %i[table strikethrough autolink])
      MarkdownTimestamper.new(doc, fixture_path('transcript.vtt')).apply!
      doc.to_html
    end

    def test_spoken_paragraph_is_timestamped
      html = render("Alright, at this point we have created the bones.\n")

      assert_match TIMESTAMP, html
    end

    def test_blockquote_paragraphs_are_not_timestamped
      html = render(<<~MD)
        > **Update Notes:** a callout the instructor reads aloud.
        >
        > Apple's Human Interface Guidelines are worth a read.
      MD

      refute_match TIMESTAMP, html, 'blockquote paragraphs should never be timestamped'
    end

    def test_nested_list_inside_a_blockquote_is_not_timestamped
      html = render(<<~MD)
        > To open the Modifiers Library:
        >
        > - Click View - Show Library and click the second button, or
        > - Press Shift-Command-L and click the second button.
      MD

      refute_match TIMESTAMP, html, 'a list nested in a blockquote should never be timestamped'
    end

    def test_a_list_gets_a_single_timestamp_rather_than_one_per_item
      html = render(<<~MD)
        A normal top level list the instructor reads:

        - One
        - Two
        - Three
      MD

      list = html[%r{<ul>.*</ul>}m]

      assert_equal 1, list.scan(TIMESTAMP).length, 'a list should carry exactly one timestamp'
      assert_match %r{<li>#{TIMESTAMP.source}\s*One</li>}, list, 'the timestamp belongs on the first item'
    end

    def test_loose_list_item_with_several_paragraphs_still_gets_one_timestamp
      html = render(<<~MD)
        - First item paragraph one.

          First item paragraph two, still the first item.
        - Second item
      MD

      list = html[%r{<ul>.*</ul>}m]

      assert_equal 1, list.scan(TIMESTAMP).length, 'a loose list should still carry exactly one timestamp'
    end
  end
end
