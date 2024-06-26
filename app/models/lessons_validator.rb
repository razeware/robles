# frozen_string_literal: true

# A validator that will check an array of choices for uniqueness of ref
class LessonsValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    return unless value.is_a?(Array)

    check_correct_class(record, attribute, value)
    check_unique_refs(record, attribute, value)
    check_unique_title(record, attribute, value)
  end

  def check_correct_class(record, attribute, value)
    value.each do |choice|
      record.errors.add(attribute, "lesson #{choice} is not a Lesson") unless choice.is_a?(Lesson)
    end
  end

  def check_unique_refs(record, attribute, value)
    return unless value.is_a?(Array)

    ref_counts = Hash.new(0)
    value.each { |lesson| ref_counts[lesson.ref] += 1 }
    non_unique_refs = ref_counts.select { |_, count| count > 1 }.keys

    non_unique_refs.each { |ref| record.errors.add(attribute, "=> ref '#{ref}' is not unique") }
  end

  def check_unique_title(record, attribute, value)
    return unless value.is_a?(Array)

    title_counts = Hash.new(0)
    value.each { |lesson| title_counts[lesson.title] += 1 }
    non_unique_titles = title_counts.select { |_, count| count > 1 }.keys

    non_unique_titles.each { |title| record.errors.add(attribute, "=> Title '#{title}' is not unique") }
  end
end
