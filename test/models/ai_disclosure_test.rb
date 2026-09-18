# frozen_string_literal: true

require_relative '../test_helper'

# Exercises the AI disclosure validations against the two real models that carry
# them. Everything here is about the *values*: the parsing of the author-facing
# keys is covered in test/parser/ai_disclosure_metadata_test.rb.
class AiDisclosureTest < Minitest::Test
  def chapter(attributes = {})
    Chapter.new({ title: 'A Chapter', number: '1', ordinal: 0, markdown_file: 'chapter.md' }.merge(attributes))
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

  def test_all_four_attributes_default_to_nil_and_are_valid_when_absent
    subject = chapter

    assert_predicate subject, :valid?
    AiDisclosure::ATTRIBUTES.each do |attribute|
      assert_nil subject.send(attribute), "expected #{attribute} to default to nil"
    end
  end

  def test_permitted_values_are_accepted
    AiDisclosure::PERMITTED_VALUES.each do |attribute, permitted|
      permitted.each do |value|
        assert_empty messages_for(chapter(attribute => value), attribute), "expected #{value.inspect} to be permitted for #{attribute}"
      end
    end
  end

  def test_a_value_that_is_not_on_the_list_is_rejected
    assert_equal 1, messages_for(chapter(ai_words: 'Written by ChatGPT'), :ai_words).length
    assert_equal 1, messages_for(chapter(ai_code: 'Vibe coded'), :ai_code).length
    assert_equal 1, messages_for(chapter(ai_media: 'Drawn by a robot'), :ai_media).length
  end

  def test_values_are_case_sensitive
    refute_empty messages_for(chapter(ai_words: 'written by the author'), :ai_words)
  end

  def test_the_error_names_the_author_facing_key_the_bad_value_and_the_permitted_values
    message = full_message_for(chapter(ai_words: 'Written by ChatGPT'), :ai_words)

    assert_includes message, '`words`'
    assert_includes message, '"Written by ChatGPT"'
    AiDisclosure::PERMITTED_VALUES[:ai_words].each do |permitted|
      assert_includes message, permitted
    end
  end

  # An inclusion validation on its own is happy to check an array element by
  # element, so `words: [Not stated]` used to pass
  def test_an_array_is_rejected_rather_than_checked_element_by_element
    message = full_message_for(chapter(ai_words: ['Not stated']), :ai_words)

    assert_includes message, 'must be text'
    assert_includes message, 'Array'
  end

  def test_an_empty_array_is_rejected
    assert_includes full_message_for(chapter(ai_media: []), :ai_media), 'must be text'
  end

  def test_a_number_is_rejected
    assert_includes full_message_for(chapter(ai_code_meta: 42), :ai_code_meta), 'must be text'
    assert_includes full_message_for(chapter(ai_code: 42), :ai_code), 'must be text'
  end

  def test_a_non_string_is_reported_once_rather_than_also_failing_the_value_checks
    assert_equal 1, messages_for(chapter(ai_code_meta: %w[one two]), :ai_code_meta).length
  end

  def test_code_meta_is_free_text
    assert_empty messages_for(chapter(ai_code_meta: 'Anything at all, really'), :ai_code_meta)
  end

  def test_code_meta_allows_up_to_four_segments
    assert_empty messages_for(chapter(ai_code_meta: 'One · Two · Three · Four'), :ai_code_meta)
  end

  def test_code_meta_rejects_five_segments
    messages = messages_for(chapter(ai_code_meta: 'One · Two · Three · Four · Five'), :ai_code_meta)

    refute_empty messages
    assert_includes messages.first, '5 segments'
  end

  def test_code_meta_rejects_a_blank_segment
    messages = messages_for(chapter(ai_code_meta: 'One ·  · Three'), :ai_code_meta)

    refute_empty messages
    assert_includes messages.first, 'blank segment'
  end

  def test_code_meta_rejects_an_empty_string_with_its_own_message
    assert_equal ['must not be blank (omit the key if there is nothing to disclose)'], messages_for(chapter(ai_code_meta: ''), :ai_code_meta)
  end

  def test_code_meta_rejects_whitespace_with_its_own_message
    assert_equal ['must not be blank (omit the key if there is nothing to disclose)'], messages_for(chapter(ai_code_meta: "  \t "), :ai_code_meta)
  end

  def test_a_wire_named_key_is_rejected_rather_than_silently_dropped
    subject = chapter(ai_disclosure_unknown_keys: [:ai_words])
    message = full_message_for(subject, :ai_words)

    assert_includes message, '`ai_words`'
    assert_includes message, '`words`'
    assert_nil subject.ai_words
  end

  def test_content_modules_share_the_same_validations
    subject = content_module(ai_words: 'Written by ChatGPT', ai_code_meta: 'One ·  · Three')

    assert_equal 1, messages_for(subject, :ai_words).length
    assert_equal 1, messages_for(subject, :ai_code_meta).length
    assert_empty messages_for(content_module(ai_words: 'Not stated'), :ai_words)
  end

  def test_errors_for_returns_nothing_when_the_disclosures_are_good
    assert_empty AiDisclosure.errors_for(chapter(ai_words: 'Not stated'))
    assert_empty AiDisclosure.errors_for(content_module)
  end

  def test_errors_for_walks_a_books_chapters_without_running_other_validations
    book = Book.new(sections: [Section.new(chapters: [chapter, chapter(ai_media: 'Drawn by a robot')])])
    messages = AiDisclosure.errors_for(book)

    assert_equal 1, messages.length
    assert_includes messages.first, 'Chapter (A Chapter)'
    assert_includes messages.first, '`media`'
    assert_includes messages.first, '"Drawn by a robot"'
  end

  def test_errors_for_does_not_trip_over_validations_that_publishing_never_ran
    # `domains` is nil here, which the existing ContentModule validations raise on
    subject = ContentModule.new(title: 'A Module', ai_words: 'Written by ChatGPT')

    assert_raises(NoMethodError) { subject.valid? }
    assert_equal 1, AiDisclosure.errors_for(subject).length
    assert_includes AiDisclosure.errors_for(subject).first, 'ContentModule (A Module)'
  end
end
