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

    def book(*chapters)
      Book.new(sections: [Section.new(chapters:)])
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
  end
end
