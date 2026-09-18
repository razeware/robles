# frozen_string_literal: true

# AI disclosure metadata, shared between chapters (book repos) and content modules.
#
# Authors write the short, unprefixed keys (`words`, `code`, `media`, `code_meta`)
# in the chapter metadata block or in `module.yaml`. robles stores them—and sends
# them to alexandria—under the `ai_`-prefixed names that alexandria permits.
#
# All four are optional: a piece of content with no disclosure keys is valid, and
# the attributes are simply `nil` on the wire.
#
# The permitted wording lives here (and only here) so that changing the options
# offered to authors is a single diff. `#ai_disclosure_violations` is likewise the
# only place that decides whether a value is acceptable: the model validation and
# the pre-publish guard in Runner::Base both read from it, so `robles lint` and
# `robles publish` cannot disagree.
# rubocop:disable Metrics/ModuleLength -- most of the length is the tables of
# permitted values, which are the point of keeping this in one place.
module AiDisclosure
  extend ActiveSupport::Concern

  # Raised by the pre-publish guard, so a bad value never reaches alexandria
  class InvalidDisclosure < StandardError; end

  # Author-facing YAML key => model attribute, which is also the wire/payload key
  ATTRIBUTE_MAP = {
    words: :ai_words,
    code: :ai_code,
    media: :ai_media,
    code_meta: :ai_code_meta
  }.freeze

  ATTRIBUTES = ATTRIBUTE_MAP.values.freeze

  # Exact, case-sensitive strings. Anything else is a linting failure.
  PERMITTED_VALUES = {
    ai_words: [
      'Written by the author',
      'Written by the author, AI-proofread',
      'Not stated'
    ].freeze,
    ai_code: [
      'Written by the author',
      'AI-assisted, author-verified',
      'AI-generated, author-verified',
      'No code in this piece',
      'Not stated'
    ].freeze,
    ai_media: [
      'Made by the author',
      'AI-generated diagrams',
      'AI voice or dubbing',
      'Made by the author, AI-generated diagrams',
      'No media in this piece',
      'Not stated'
    ].freeze
  }.freeze

  # `code_meta` is free text: up to four non-blank segments, separated by a middot
  CODE_META_SEPARATOR = '·'
  CODE_META_MAX_SEGMENTS = 4

  class << self
    # The author-facing key for a model attribute, e.g. :ai_words => :words
    def author_key(attribute)
      ATTRIBUTE_MAP.key(attribute.to_sym)
    end

    # Annotation-style messages for every record carrying disclosure metadata,
    # *without* running any of the other model validations—the publish path has
    # never run them, and some of them raise on incomplete models.
    def errors_for(subject)
      records_for(subject).flat_map do |record|
        record.ai_disclosure_violations.map do |attribute, message|
          "#{record.class} (#{record.validation_name || 'unknown'}): #{record.class.human_attribute_name(attribute)} #{message}"
        end
      end
    end

    def inclusion_message(attribute, value)
      permitted = PERMITTED_VALUES.fetch(attribute)
      "#{value.inspect} is not a permitted value. Use one of: #{permitted.map(&:inspect).join(', ')}"
    end

    def type_message(value)
      "must be text, but was #{value.class} (#{value.inspect})"
    end

    private

    def records_for(subject)
      return subject.sections.flat_map(&:chapters) if subject.respond_to?(:sections)

      Array.wrap(subject)
    end
  end

  included do
    attr_accessor(*ATTRIBUTES)
    # Populated by the parser with any `ai_`-prefixed keys the author used by mistake
    attr_accessor :ai_disclosure_unknown_keys

    validate :validate_ai_disclosure
  end

  class_methods do
    # Annotations are read by authors, who know the key as `words`, not `ai_words`
    def human_attribute_name(attribute, options = {})
      return "AI disclosure `#{AiDisclosure.author_key(attribute)}`" if ATTRIBUTES.include?(attribute.to_sym)

      super
    end
  end

  # Every disclosure problem with this record, as [attribute, message] pairs
  def ai_disclosure_violations
    ATTRIBUTES.flat_map { |attribute| violations_for(attribute) } + prefixed_key_violations
  end

  private

  def validate_ai_disclosure
    ai_disclosure_violations.each { |attribute, message| errors.add(attribute, message) }
  end

  def violations_for(attribute)
    value = send(attribute)
    return [] if value.nil?
    return [[attribute, AiDisclosure.type_message(value)]] unless value.is_a?(String)
    return code_meta_violations(value) if attribute == :ai_code_meta
    return [] if PERMITTED_VALUES.fetch(attribute).include?(value)

    [[attribute, AiDisclosure.inclusion_message(attribute, value)]]
  end

  def code_meta_violations(value)
    return [[:ai_code_meta, 'must not be blank (omit the key if there is nothing to disclose)']] if value.strip.blank?

    segments = value.split(CODE_META_SEPARATOR, -1)

    [].tap do |violations|
      violations << [:ai_code_meta, too_many_segments_message(segments, value)] if segments.length > CODE_META_MAX_SEGMENTS
      violations << [:ai_code_meta, blank_segment_message(value)] unless segments.all? { |segment| segment.strip.present? }
    end
  end

  # The wire names are silently dropped by the metadata slice, so an author who
  # writes `ai_words` would otherwise clear a published value without a warning
  def prefixed_key_violations
    Array.wrap(ai_disclosure_unknown_keys).filter_map do |key|
      attribute = key.to_sym
      next unless ATTRIBUTES.include?(attribute)

      [attribute, "was given as `#{attribute}`: use the unprefixed key `#{AiDisclosure.author_key(attribute)}` instead"]
    end
  end

  def too_many_segments_message(segments, value)
    "has #{segments.length} segments, but at most #{CODE_META_MAX_SEGMENTS} segments separated by '#{CODE_META_SEPARATOR}' are allowed: #{value.inspect}"
  end

  def blank_segment_message(value)
    "has a blank segment: every segment separated by '#{CODE_META_SEPARATOR}' must contain text (#{value.inspect})"
  end

  # Defaults for the serialisation allow-list, to be merged into `#attributes`
  def ai_disclosure_defaults
    ATTRIBUTES.index_with(nil).stringify_keys
  end
end
# rubocop:enable Metrics/ModuleLength
