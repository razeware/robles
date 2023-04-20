# frozen_string_literal: true

# A validator that will check an array of choices for uniqueness of ref
class ChoicesValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    return unless value.is_a?(Array)

    check_correct_class(record, attribute, value)
    check_unique_refs(record, attribute, value)
    check_one_correct(record, attribute, value)
  end

  def check_correct_class(record, attribute, value)
    value.each do |choice|
      record.errors.add(attribute, "choice #{choice} is not an Assessment::Choice") unless choice.is_a?(Assessment::Choice)
    end
  end

  def check_unique_refs(record, attribute, value)
    return unless value.is_a?(Array)

    ref_counts = value.map(&:ref).each_with_object(Hash.new(0)) { |ref, counts| counts[ref] += 1 }
    ref_counts.each do |ref, count|
      next if count == 1

      record.errors.add(attribute, "choice ref #{ref} is not unique")
    end
  end

  def check_one_correct(record, attribute, value)
    return unless value.is_a?(Array)

    correct_choices = value.select(&:correct)
    if correct_choices.count > 1
      record.errors.add(attribute, 'more than one choice is correct')
    elsif correct_choices.count < 1
      record.errors.add(attribute, 'no choice is correct')
    end
  end
end
