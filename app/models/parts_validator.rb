# frozen_string_literal: true

# A validator that will check an array of choices for uniqueness of ref
class PartsValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    return unless value.is_a?(Array)

    check_correct_class(record, attribute, value)
    check_unique_refs(record, attribute, value)
  end

  def check_correct_class(record, attribute, value)
    value.each do |part|
      record.errors.add(attribute, "part #{choice} is not a Part") unless part.is_a?(Part)
    end
  end

  def check_unique_refs(record, attribute, value)
    return unless value.is_a?(Array)

    episodes = value.flat_map(&:episodes)

    ref_counts = episodes.map(&:ref).each_with_object(Hash.new(0)) { |ref, counts| counts[ref] += 1 }
    ref_counts.each do |ref, count|
      next if count == 1

      record.errors.add(attribute, "episode ref #{ref} is not unique")
    end
  end
end
