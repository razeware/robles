# frozen_string_literal: true

require_relative '../test_helper'

module Parser
  # Parses real fixture repos (a book and a content module) to check that the
  # author-facing disclosure keys make it onto the models under their `ai_`
  # prefixed names, reach the payload alexandria receives, and fail linting when
  # they are wrong.
  class AiDisclosureMetadataTest < Minitest::Test
    include TestHelpers

    AI_KEYS = %w[ai_words ai_code ai_media ai_code_meta].freeze
    AUTHOR_KEYS = %w[words code media code_meta].freeze

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

    def test_the_disclosure_keys_reach_the_chapter_payload
      payload = chapter_payload(0)

      assert_equal 'Written by the author, AI-proofread', payload['ai_words']
      assert_equal 'AI-assisted, author-verified', payload['ai_code']
      assert_equal 'Made by the author, AI-generated diagrams', payload['ai_media']
      assert_equal 'Claude Code · Xcode 16 · author reviewed', payload['ai_code_meta']
    end

    def test_the_unprefixed_keys_are_not_sent_to_alexandria
      assert_empty chapter_payload(0).keys & AUTHOR_KEYS
    end

    def test_a_chapter_with_disclosures_is_valid
      assert_predicate chapters.first, :valid?
    end

    def test_a_chapter_without_disclosures_is_valid_and_sends_the_keys_as_nil
      assert_predicate chapters.second, :valid?

      payload = chapter_payload(1)

      assert_equal AI_KEYS.sort, (payload.keys & AI_KEYS).sort
      AI_KEYS.each { |key| assert_nil payload[key], "expected #{key} to be sent as null" }
    end

    def test_a_chapter_with_an_unpermitted_value_fails_linting
      chapter = chapters.third

      refute_predicate chapter, :valid?

      message = disclosure_annotations(book_annotations).map(&:message).find { _1.include?('is not a permitted value') }

      assert_includes message, '`words`'
      assert_includes message, '"Written by ChatGPT"'
      assert_includes message, 'Written by the author, AI-proofread'
    end

    def test_a_chapter_using_a_wire_named_key_fails_linting
      chapter = chapters.fourth

      refute_predicate chapter, :valid?
      assert_nil chapter.ai_words, 'the prefixed key must not be honoured'

      message = disclosure_annotations(book_annotations).map(&:message).find { _1.include?('`ai_words`') }

      assert_includes message, 'use the unprefixed key `words`'
    end

    def test_only_the_two_bad_chapters_are_annotated
      assert_equal 2, disclosure_annotations(book_annotations).length
    end

    def test_the_publish_guard_reports_the_same_problems_as_linting
      messages = AiDisclosure.errors_for(book)

      assert_equal 2, messages.length
      assert(messages.any? { _1.include?('Chapter (Invalid Chapter)') && _1.include?('"Written by ChatGPT"') })
      assert(messages.any? { _1.include?('Chapter (Prefixed Chapter)') && _1.include?('`ai_words`') })
    end

    def test_the_disclosure_keys_reach_the_content_module_payload
      payload = module_payload(content_module)

      assert_equal 'Written by the author', payload['ai_words']
      assert_equal 'No code in this piece', payload['ai_code']
      assert_equal 'AI voice or dubbing', payload['ai_media']
      assert_equal 'Claude Code · author reviewed', payload['ai_code_meta']
      assert_empty payload.keys & AUTHOR_KEYS
    end

    def test_a_content_module_with_no_disclosures_sends_the_keys_as_nil
      payload = module_payload(::ContentModule.new)

      assert_equal AI_KEYS.sort, (payload.keys & AI_KEYS).sort
      AI_KEYS.each { |key| assert_nil payload[key], "expected #{key} to be sent as null" }
    end

    def test_a_content_module_with_bad_disclosures_fails_linting_and_the_publish_guard
      subject = content_module('ai_disclosure_module_invalid')
      file = fixture_path('ai_disclosure_module_invalid/module.yaml')

      refute_predicate subject, :valid?

      messages = disclosure_annotations(Linting::Validations::ContentModule.new(content_module: subject, file:).lint).map(&:message)

      assert_includes messages.find { _1.include?('`media`') }, '"Drawn by a robot"'
      assert_includes messages.find { _1.include?('`ai_code`') }, 'use the unprefixed key `code`'
      assert_equal 2, AiDisclosure.errors_for(subject).length
    end
  end
end
