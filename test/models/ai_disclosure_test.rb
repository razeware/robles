# frozen_string_literal: true

require_relative '../test_helper'

# Exercises the AI disclosure validations and the wire values against the two
# real models that carry them. Everything here is about the *block*: the parsing
# of it out of a markdown file or module.yaml is covered in
# test/parser/ai_disclosure_metadata_test.rb.
class AiDisclosureTest < Minitest::Test
  FULL_BLOCK = {
    words: 'author_written_ai_edited',
    code: 'ai_assisted',
    media: { diagrams: 'ai', illustrations: 'author', voice: 'other_human' },
    code_meta: { tokens: '2.1M', approximate_cost: '$0.90', model: 'Claude Opus 4.1', date: 'Sep 2026' }
  }.freeze

  def chapter(attributes = {})
    Chapter.new({ title: 'A Chapter', number: '1', ordinal: 0, markdown_file: 'chapter.md' }.merge(attributes))
  end

  def disclosed(block)
    chapter(ai_disclosure: FULL_BLOCK.merge(block))
  end

  def content_module(attributes = {})
    # `domains` is required by an existing validation that cannot cope with nil
    ContentModule.new({ domains: [] }.merge(attributes))
  end

  def messages_for(record, attribute)
    record.valid?
    record.errors.messages_for(attribute)
  end

  def full_message_for(record, attribute)
    record.valid?
    record.errors.full_messages_for(attribute).first
  end

  # --- Absent block ----------------------------------------------------------

  def test_a_record_with_no_block_is_valid_and_every_wire_attribute_is_nil
    subject = chapter

    assert_predicate subject, :valid?
    AiDisclosure::ATTRIBUTES.each do |attribute|
      assert_nil subject.send(attribute), "expected #{attribute} to default to nil"
    end
  end

  def test_an_empty_block_is_valid_and_discloses_nothing
    subject = chapter(ai_disclosure: {})

    assert_predicate subject, :valid?
    AiDisclosure::ATTRIBUTES.each { |attribute| assert_nil subject.send(attribute) }
  end

  # --- Wire values -----------------------------------------------------------

  def test_words_and_code_go_on_the_wire_as_the_token_the_author_wrote
    subject = disclosed({})

    assert_predicate subject, :valid?
    assert_equal 'author_written_ai_edited', subject.ai_words
    assert_equal 'ai_assisted', subject.ai_code
  end

  def test_media_goes_on_the_wire_as_json_keyed_by_type
    assert_equal({ 'diagrams' => 'ai', 'illustrations' => 'author', 'voice' => 'other_human' },
                 JSON.parse(disclosed({}).ai_media))
  end

  def test_media_json_carries_only_the_types_the_author_answered
    subject = disclosed(media: { voice: 'ai' })

    assert_equal({ 'voice' => 'ai' }, JSON.parse(subject.ai_media))
  end

  def test_code_meta_is_joined_in_a_fixed_order_whatever_order_the_author_used
    subject = disclosed(code_meta: { date: 'Sep 2026', model: 'Claude Opus 4.1', approximate_cost: '$0.90', tokens: '2.1M' })

    assert_equal '2.1M · $0.90 · Claude Opus 4.1 · Sep 2026', subject.ai_code_meta
  end

  def test_code_meta_omits_the_keys_the_author_left_out
    assert_equal '2.1M · Sep 2026', disclosed(code_meta: { tokens: '2.1M', date: 'Sep 2026' }).ai_code_meta
  end

  # YAML hands us an Integer for `tokens: 2100000` and a Date for
  # `date: 2026-09-21`, both of which are lines as far as the card is concerned
  def test_code_meta_values_that_yaml_did_not_parse_as_strings_are_coerced
    subject = disclosed(code_meta: { tokens: 2_100_000, date: Date.new(2026, 9, 21) })

    assert_predicate subject, :valid?
    assert_equal '2100000 · 2026-09-21', subject.ai_code_meta
  end

  def test_an_answer_the_author_did_not_give_is_nil_rather_than_blank
    subject = chapter(ai_disclosure: { words: 'not_stated' })

    assert_equal 'not_stated', subject.ai_words
    assert_nil subject.ai_code
    assert_nil subject.ai_media
    assert_nil subject.ai_code_meta
  end

  # --- words and code --------------------------------------------------------

  def test_every_permitted_token_is_accepted
    AiDisclosure::PERMITTED_VALUES.each do |key, tokens|
      tokens.each do |token|
        subject = chapter(ai_disclosure: { key => token })

        assert_empty messages_for(subject, AiDisclosure::ATTRIBUTE_MAP.fetch(key)),
                     "expected #{token.inspect} to be permitted for #{key}"
      end
    end
  end

  def test_a_token_that_is_not_on_the_list_is_rejected
    assert_equal 1, messages_for(chapter(ai_disclosure: { words: 'written_by_chatgpt' }), :ai_words).length
    assert_equal 1, messages_for(chapter(ai_disclosure: { code: 'vibe_coded' }), :ai_code).length
  end

  # The old interface took prose, so an author working from a stale example gets
  # told what the tokens are rather than a silent pass
  def test_the_prose_from_the_previous_interface_is_rejected
    refute_empty messages_for(chapter(ai_disclosure: { words: 'Written by the author' }), :ai_words)
  end

  def test_tokens_are_case_sensitive
    refute_empty messages_for(chapter(ai_disclosure: { words: 'Author_Written' }), :ai_words)
  end

  def test_the_error_names_the_author_facing_key_the_bad_token_and_the_permitted_tokens
    message = full_message_for(chapter(ai_disclosure: { words: 'written_by_chatgpt' }), :ai_words)

    assert_includes message, '`words`'
    assert_includes message, '"written_by_chatgpt"'
    AiDisclosure::PERMITTED_VALUES[:words].each { |token| assert_includes message, token }
  end

  # An inclusion check on its own is happy to walk an array element by element
  def test_a_list_is_rejected_rather_than_checked_element_by_element
    message = full_message_for(chapter(ai_disclosure: { words: ['not_stated'] }), :ai_words)

    assert_includes message, 'must be text'
    assert_includes message, 'Array'
  end

  def test_a_number_is_rejected
    assert_includes full_message_for(chapter(ai_disclosure: { code: 42 }), :ai_code), 'must be text'
  end

  # --- The block itself ------------------------------------------------------

  def test_a_block_that_is_not_a_block_is_rejected
    message = full_message_for(chapter(ai_disclosure: 'author_written'), :ai_disclosure)

    assert_includes message, 'AI disclosure must be a block of'
    assert_includes message, 'words, code, media, code_meta'
  end

  def test_an_unknown_key_in_the_block_is_rejected
    message = full_message_for(chapter(ai_disclosure: { wordz: 'author_written' }), :ai_disclosure)

    assert_includes message, 'unknown key `wordz`'
    assert_includes message, 'words, code, media, code_meta'
  end

  def test_a_disclosure_key_written_outside_the_block_is_rejected_rather_than_dropped
    subject = chapter(ai_disclosure_misplaced_keys: %i[words])
    message = full_message_for(subject, :ai_words)

    assert_includes message, '`words`'
    assert_includes message, 'nest it inside the `ai_disclosure` block'
    assert_nil subject.ai_words
  end

  def test_a_wire_name_written_outside_the_block_is_rejected_too
    message = full_message_for(chapter(ai_disclosure_misplaced_keys: %i[ai_code]), :ai_code)

    assert_includes message, '`ai_code`'
    assert_includes message, 'nest it inside the `ai_disclosure` block'
  end

  def test_a_misplaced_key_is_reported_even_when_the_block_is_absent
    assert_equal 1, AiDisclosure.errors_for(chapter(ai_disclosure_misplaced_keys: %i[media])).length
  end

  # Psych only symbolises string keys, so `2: ai` arrives as an Integer and used
  # to take `to_sym` with it
  def test_a_key_that_is_not_a_string_is_reported_rather_than_crashing_the_linter
    assert_includes full_message_for(chapter(ai_disclosure: { 2 => 'ai' }), :ai_disclosure), 'unknown key `2`'
    assert_includes full_message_for(chapter(ai_disclosure: { media: { 2 => 'ai' } }), :ai_media), 'unknown media type `2`'
  end

  # --- media -----------------------------------------------------------------

  def test_every_permitted_media_value_is_accepted_for_every_type
    AiDisclosure::MEDIA_TYPES.each do |type|
      AiDisclosure::MEDIA_VALUES.each do |value|
        subject = chapter(ai_disclosure: { media: { type => value } })

        assert_empty messages_for(subject, :ai_media), "expected #{value.inspect} to be permitted for #{type}"
      end
    end
  end

  def test_media_must_be_a_block_of_types_rather_than_a_single_answer
    message = full_message_for(chapter(ai_disclosure: { media: 'ai' }), :ai_media)

    assert_includes message, 'must be a block of diagrams, illustrations, voice'
  end

  def test_an_empty_media_block_is_rejected
    assert_includes full_message_for(chapter(ai_disclosure: { media: {} }), :ai_media), 'must list at least one of'
  end

  def test_an_unknown_media_type_is_rejected
    message = full_message_for(chapter(ai_disclosure: { media: { screenshots: 'author' } }), :ai_media)

    assert_includes message, 'unknown media type `screenshots`'
    assert_includes message, 'diagrams, illustrations, voice'
  end

  def test_an_unknown_media_value_is_rejected_and_names_the_type
    message = full_message_for(chapter(ai_disclosure: { media: { diagrams: 'drawn_by_a_robot' } }), :ai_media)

    assert_includes message, '`diagrams` is "drawn_by_a_robot"'
    assert_includes message, 'author, ai, other_human, none'
  end

  def test_each_bad_media_type_is_reported_separately
    subject = chapter(ai_disclosure: { media: { diagrams: 'robot', voice: 'synth' } })

    assert_equal 2, messages_for(subject, :ai_media).length
  end

  # --- voice on a module with video ------------------------------------------

  def video_module(block)
    content_module(
      ai_disclosure: block,
      lessons: [Lesson.new(segments: [Video.new(title: 'A Video')])]
    )
  end

  def test_a_video_module_that_discloses_must_answer_voice
    message = full_message_for(video_module(words: 'author_written', media: { diagrams: 'ai' }), :ai_media)

    assert_includes message, 'must include `voice`'
    assert_includes message, 'because this module contains video'
  end

  def test_a_video_module_that_answers_voice_is_accepted
    assert_empty messages_for(video_module(media: { voice: 'other_human' }), :ai_media)
  end

  def test_a_video_module_that_omits_media_entirely_is_still_asked_for_voice
    refute_empty messages_for(video_module(words: 'author_written'), :ai_media)
  end

  # Every module published before this existed has no block at all, and must not
  # start failing its build because of it
  def test_a_video_module_with_no_block_is_left_alone
    assert_empty messages_for(video_module(nil), :ai_media)
  end

  def test_a_module_without_video_is_not_asked_for_voice
    subject = content_module(ai_disclosure: { media: { diagrams: 'ai' } }, lessons: [Lesson.new(segments: [Text.new])])

    assert_empty messages_for(subject, :ai_media)
  end

  def test_chapters_are_never_asked_for_voice
    assert_empty messages_for(chapter(ai_disclosure: { media: { diagrams: 'ai' } }), :ai_media)
  end

  # --- code_meta -------------------------------------------------------------

  def test_code_meta_must_be_a_block
    message = full_message_for(chapter(ai_disclosure: { code: 'ai_assisted', code_meta: '2.1M · $0.90' }), :ai_code_meta)

    assert_includes message, 'must be a block of tokens, approximate_cost, model, date'
  end

  def test_an_empty_code_meta_block_is_rejected
    subject = chapter(ai_disclosure: { code: 'ai_assisted', code_meta: {} })

    assert_includes full_message_for(subject, :ai_code_meta), 'must list at least one of'
  end

  def test_an_unknown_code_meta_key_is_rejected
    subject = chapter(ai_disclosure: { code: 'ai_assisted', code_meta: { sessions: '3' } })
    message = full_message_for(subject, :ai_code_meta)

    assert_includes message, 'unknown key `sessions`'
    assert_includes message, 'tokens, approximate_cost, model, date'
  end

  def test_a_blank_code_meta_value_is_rejected
    subject = chapter(ai_disclosure: { code: 'ai_assisted', code_meta: { tokens: '  ' } })

    assert_includes full_message_for(subject, :ai_code_meta), '`tokens` must not be blank'
  end

  def test_a_nested_code_meta_value_is_rejected
    subject = chapter(ai_disclosure: { code: 'ai_assisted', code_meta: { model: { name: 'Claude' } } })

    assert_includes full_message_for(subject, :ai_code_meta), '`model` must be text'
  end

  # `code_meta` is the detail behind the `code` answer, so it cannot sit next to
  # an answer that says no AI wrote any code
  def test_code_meta_contradicting_the_code_answer_is_rejected
    %w[none author_written].each do |token|
      subject = chapter(ai_disclosure: { code: token, code_meta: { tokens: '2.1M' } })

      assert_includes full_message_for(subject, :ai_code_meta), "`code` is `#{token}`"
    end
  end

  def test_code_meta_alongside_an_ai_code_answer_is_accepted
    assert_empty messages_for(chapter(ai_disclosure: { code: 'ai_generated', code_meta: { tokens: '2.1M' } }), :ai_code_meta)
  end

  # --- errors_for ------------------------------------------------------------

  def test_errors_for_returns_nothing_when_the_disclosure_is_good
    assert_empty AiDisclosure.errors_for(disclosed({}))
    assert_empty AiDisclosure.errors_for(content_module)
  end

  def test_errors_for_walks_a_books_chapters_without_running_other_validations
    book = Book.new(sections: [Section.new(chapters: [chapter, chapter(ai_disclosure: { media: { diagrams: 'robot' } })])])
    messages = AiDisclosure.errors_for(book)

    assert_equal 1, messages.length
    assert_includes messages.first, 'Chapter (A Chapter)'
    assert_includes messages.first, '`media`'
    assert_includes messages.first, '"robot"'
  end

  def test_errors_for_does_not_trip_over_validations_that_publishing_never_ran
    # `domains` is nil here, which the existing ContentModule validations raise on
    subject = ContentModule.new(title: 'A Module', ai_disclosure: { words: 'written_by_chatgpt' })

    assert_raises(NoMethodError) { subject.valid? }
    assert_equal 1, AiDisclosure.errors_for(subject).length
    assert_includes AiDisclosure.errors_for(subject).first, 'ContentModule (A Module)'
  end
end
