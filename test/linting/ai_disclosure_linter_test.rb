# frozen_string_literal: true

require_relative '../test_helper'

module Linting
  # A missing disclosure is a warning, never a failure: see AiDisclosureLinter.
  class AiDisclosureLinterTest < Minitest::Test
    BLOCK = { words: 'author_written', code: 'none' }.freeze
    MODULE_FILE = '/repo/module.yaml'

    def setup
      Linting::Annotation.root_directory = Pathname.new('/repo')
    end

    def chapter(number, attributes = {})
      Chapter.new({ title: "Chapter #{number}", number: number.to_s, ordinal: number,
                    markdown_file: "/repo/chapters/0#{number}.md" }.merge(attributes))
    end

    def book(*chapters, released_at: nil)
      Book.new(released_at:, sections: [Section.new(chapters:)])
    end

    def content_module(attributes = {})
      ContentModule.new({ shortcode: 'devtest', domains: [] }.merge(attributes))
    end

    def lint(subject)
      AiDisclosureLinter.new(subject:, file: MODULE_FILE).lint
    end

    def test_a_chapter_with_no_block_gets_a_warning_on_its_own_file
      annotations = lint(book(chapter(1, ai_disclosure: BLOCK), chapter(2)))

      assert_equal 1, annotations.size
      assert_equal 'warning', annotations.first.annotation_level
      assert_equal 'Missing AI disclosure', annotations.first.title
      assert_equal 'chapters/02.md', annotations.first.path
      assert_match(/has no `ai_disclosure` block/, annotations.first.message)
    end

    def test_an_empty_block_discloses_nothing_so_it_is_missing_too
      assert_equal 1, lint(book(chapter(1, ai_disclosure: {}))).size
    end

    def test_a_chapter_with_a_block_gets_no_warning
      assert_empty lint(book(chapter(1, ai_disclosure: BLOCK)))
    end

    # Those already fail validation, which says where the keys should go
    def test_keys_written_outside_the_block_are_not_also_reported_as_missing
      assert_empty lint(book(chapter(1, ai_disclosure_misplaced_keys: [:words])))
    end

    def test_a_module_with_no_block_gets_a_warning_on_module_yaml
      annotations = lint(content_module)

      assert_equal ['module.yaml'], annotations.map(&:path)
      assert_match(/at the top level of module\.yaml/, annotations.first.message)
    end

    def test_a_module_with_a_block_gets_no_warning
      assert_empty lint(content_module(ai_disclosure: BLOCK))
    end

    # --- Released before the policy ------------------------------------------

    def test_a_book_released_before_the_policy_gets_no_warnings
      assert_empty lint(book(chapter(1), chapter(2), released_at: Date.new(2026, 10, 10)))
    end

    def test_a_module_released_before_the_policy_gets_no_warning
      assert_empty lint(content_module(released_at: Date.new(2025, 3, 1)))
    end

    # The same rule carolus uses for its pre-policy notice: strictly before
    def test_a_book_released_on_the_policy_date_is_asked_for_a_disclosure
      assert_equal 2, lint(book(chapter(1), chapter(2), released_at: AiDisclosure::POLICY_DATE)).size
    end

    def test_a_module_released_after_the_policy_is_asked_for_a_disclosure
      assert_equal 1, lint(content_module(released_at: Date.new(2026, 11, 1))).size
    end

    def test_a_quoted_release_date_is_read_too
      assert_empty lint(book(chapter(1), released_at: '2026-09-01'))
    end

    def test_a_release_date_that_cannot_be_read_still_gets_the_warning
      assert_equal 1, lint(book(chapter(1), released_at: 'soon')).size
      assert_equal 1, lint(book(chapter(1), released_at: nil)).size
    end

    # --- Front matter ----------------------------------------------------------

    def test_dedications_and_team_bios_are_never_asked_for_a_disclosure
      annotations = lint(book(chapter(1, kind: 'dedications'), chapter(2, kind: 'team-bios'), chapter(3)))

      assert_equal ['chapters/03.md'], annotations.map(&:path)
    end

    def test_a_chapter_that_says_not_applicable_gets_no_warning
      assert_empty lint(book(chapter(1, ai_disclosure: AiDisclosure::NOT_APPLICABLE)))
    end

    def test_a_chapter_warning_says_how_to_opt_front_matter_out
      assert_match(/`ai_disclosure: not_applicable`/, lint(book(chapter(1))).first.message)
    end

    def test_a_module_warning_does_not_offer_the_opt_out
      refute_match(/not_applicable/, lint(content_module).first.message)
    end
  end
end
