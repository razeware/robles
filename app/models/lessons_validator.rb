# frozen_string_literal: true

# A validator that will check an array of choices for uniqueness of ref
class LessonsValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    return unless value.is_a?(Array)

    check_correct_class(record, attribute, value)
    check_unique_refs(record, attribute, value)
  end

  def check_correct_class(record, attribute, value)
    value.each do |choice|
      record.errors.add(attribute, "lesson #{choice} is not a Lesson") unless choice.is_a?(Lesson)
    end
  end

  def check_unique_refs(record, attribute, value)
    return unless value.is_a?(Array)

    value.each do |lesson|
      ref_counts = Hash.new(0)
      lesson.segments.each { |segment| ref_counts[segment.ref] += 1 }
      non_unique_refs = ref_counts.select { |_, count| count > 1 }.keys

      non_unique_refs.each { |ref| record.errors.add(attribute, "segment ref #{ref} is not unique") }
    end
  end
end
