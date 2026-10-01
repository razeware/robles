# frozen_string_literal: true

require_relative '../test_helper'

module Parser
  # Parses real fixture repos (a book and a content module) to check that the
  # author's `ai_disclosure` block reaches the payload alexandria receives as the
  # four `ai_`-prefixed wire attributes, and fails linting when it is wrong.
  class AiDisclosureMetadataTest < Minitest::Test
    include TestHelpers

    AI_KEYS = %w[ai_words ai_code ai_media ai_code_meta].freeze
    AUTHOR_KEYS = %w[ai_disclosure words code media code_meta].freeze

    def book
      @book ||= Parser::Publish.new(file: publish_file).parse
    end

    def publish_file
      fixture_path('ai_disclosure_book/publish.yaml')
    end

    def chapters
      book.sections.first.chapters
    end

    def content_module(fixture = 'ai_disclosure_module')
      Parser::Circulate.new(file: fixture_path("#{fixture}/module.yaml")).parse
    end

    # The payload alexandria actually receives, built by the real uploader
    def book_payload
      @book_payload ||= JSON.parse(Api::Alexandria::BookUploader.new(book).send(:payload))
    end

    def chapter_payload(index)
      book_payload['book']['sections'].first['chapters'][index]
    end

    def module_payload(subject)
      JSON.parse(Api::Alexandria::ContentModuleUploader.new(subject).send(:payload))['content_module']
    end

    def book_annotations
      Linting::Validations::Book.new(book:, file: publish_file).lint
    end

    def disclosure_annotations(annotations)
      annotations.select { _1.message.include?('AI disclosure') }
    end

    def test_the_block_reaches_the_chapter_payload_as_the_wire_attributes
      payload = chapter_payload(0)

      assert_equal 'author_written_ai_edited', payload['ai_words']
      assert_equal 'ai_assisted', payload['ai_code']
      assert_equal({ 'diagrams' => 'ai', 'illustrations' => 'author' }, JSON.parse(payload['ai_media']))
      assert_equal '2.1M · $0.90 · Claude Opus 4.1 · Sep 2026', payload['ai_code_meta']
    end

    # `$0.90` and `2.1M` are plain YAML scalars, and `Sep 2026` is not a date
    def test_the_code_meta_values_survive_yaml_as_the_author_typed_them
      assert_equal '2.1M · $0.90 · Claude Opus 4.1 · Sep 2026', chapters.first.ai_code_meta
    end

    def test_the_block_itself_is_not_sent_to_alexandria
      assert_empty chapter_payload(0).keys & AUTHOR_KEYS
    end

    def test_a_chapter_with_a_disclosure_is_valid
      assert_predicate chapters.first, :valid?
    end

    def test_a_chapter_without_a_block_is_valid_and_sends_the_keys_as_nil
      assert_predicate chapters.second, :valid?

      payload = chapter_payload(1)

      assert_equal AI_KEYS.sort, (payload.keys & AI_KEYS).sort
      AI_KEYS.each { |key| assert_nil payload[key], "expected #{key} to be sent as null" }
    end

    def test_a_chapter_with_an_unpermitted_token_fails_linting
      refute_predicate chapters.third, :valid?

      message = disclosure_annotations(book_annotations).map(&:message).find { _1.include?('is not a permitted value') }

      assert_includes message, '`words`'
      assert_includes message, '"written_by_chatgpt"'
      assert_includes message, 'author_written_ai_edited'
    end

    def test_a_chapter_writing_a_key_outside_the_block_fails_linting
      chapter = chapters.fourth

      refute_predicate chapter, :valid?
      assert_nil chapter.ai_words, 'a key outside the block must not be honoured'

      message = disclosure_annotations(book_annotations).map(&:message).find { _1.include?('at the top level') }

      assert_includes message, 'nest it inside the `ai_disclosure` block'
    end

    def test_only_the_two_bad_chapters_are_annotated
      assert_equal 2, disclosure_annotations(book_annotations).length
    end

    def test_the_publish_guard_reports_the_same_problems_as_linting
      messages = AiDisclosure.errors_for(book)

      assert_equal 2, messages.length
      assert(messages.any? { _1.include?('Chapter (Invalid Chapter)') && _1.include?('"written_by_chatgpt"') })
      assert(messages.any? { _1.include?('Chapter (Misplaced Chapter)') && _1.include?('at the top level') })
    end

    # This fixture's module.yaml is the agreed block verbatim, so these four
    # assertions are the interface contract with alexandria and carolus
    def test_the_block_reaches_the_content_module_payload
      payload = module_payload(content_module)

      assert_equal 'author_written_ai_edited', payload['ai_words']
      assert_equal 'ai_assisted', payload['ai_code']
      assert_equal({ 'diagrams' => 'ai', 'illustrations' => 'author', 'voice' => 'other_human' },
                   JSON.parse(payload['ai_media']))
      assert_equal '2.1M · $0.90 · Claude Opus 4.1 · Sep 2026', payload['ai_code_meta']
      assert_empty payload.keys & AUTHOR_KEYS
    end

    def test_a_content_module_with_no_block_sends_the_keys_as_nil
      payload = module_payload(::ContentModule.new)

      assert_equal AI_KEYS.sort, (payload.keys & AI_KEYS).sort
      AI_KEYS.each { |key| assert_nil payload[key], "expected #{key} to be sent as null" }
    end

    def test_a_content_module_with_a_bad_block_fails_linting_and_the_publish_guard
      subject = content_module('ai_disclosure_module_invalid')
      file = fixture_path('ai_disclosure_module_invalid/module.yaml')

      refute_predicate subject, :valid?

      messages = disclosure_annotations(Linting::Validations::ContentModule.new(content_module: subject, file:).lint).map(&:message)

      assert_includes messages.find { _1.include?('`media`') }, '"drawn_by_a_robot"'
      assert_includes messages.find { _1.include?('`ai_code`') }, 'nest it inside the `ai_disclosure` block'
      assert_equal 2, AiDisclosure.errors_for(subject).length
    end
  end
end
