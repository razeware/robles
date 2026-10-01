# frozen_string_literal: true

require_relative '../../test_helper'

module Linting
  module Markdown
    # Characterisation tests for the word counter that drives the 4,000 word
    # lint warning. What counts as a "word" is the contract here.
    class WordCounterTest < Minitest::Test
      include TestHelpers

      def count(markdown)
        WordCounter.new(markdown).count
      end

      def test_counts_the_prose_corpus
        assert_equal 107, count(File.read(fixture_path('markdown/prose.md')))
      end

      def test_counts_plain_words
        assert_equal 4, count('One two three four.')
      end

      def test_markup_characters_are_not_counted
        assert_equal 2, count('**bold** *emphasis*')
      end

      def test_link_text_counts_but_the_url_does_not
        assert_equal 2, count('[the label](https://kodeco.com/library)')
      end

      # Inline code counts as prose; the body of a fenced block does not, so the
      # three words here are "Use", "let" and "here." and not the code.
      def test_inline_code_counts_but_a_fenced_block_does_not
        assert_equal 3, count("Use `let` here.\n\n```swift\nlet x = 1\n```\n")
        assert_equal 0, count("```swift\nlet x = 1\n```\n")
      end

      # The word counter parses with no extensions, so the table is not a table:
      # the pipes and dashes are counted as ordinary words.
      def test_headings_list_items_and_unparsed_table_rows_are_counted
        markdown = <<~MD
          # A heading

          - item one
          - item two

          | A | B |
          | - | - |
          | 1 | 2 |
        MD

        assert_equal 16, count(markdown)
      end

      def test_image_alt_text_is_counted
        assert_equal 2, count('![width=50% bordered](assets/shot.png)')
      end

      def test_exceeds_word_limit_is_driven_by_the_count
        refute WordCounter.new('a ' * 4000).exceeds_word_limit?
        assert WordCounter.new('a ' * 4001).exceeds_word_limit?
      end
    end
  end
end
