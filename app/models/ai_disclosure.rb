# frozen_string_literal: true

# AI disclosure metadata, shared between chapters (book repos) and content modules.
#
# Authors fill in a single `ai_disclosure` block, either in the chapter metadata
# block or at the top level of `module.yaml`:
#
#   ai_disclosure:
#     words: author_written_ai_edited
#     code: ai_assisted
#     media:
#       diagrams: ai
#       illustrations: author
#       voice: other_human
#     code_meta:
#       tokens: 2.1M
#       approximate_cost: $0.90
#       model: Claude Opus 4.1
#       date: Sep 2026
#
# Every value is a token, not a phrase: the reader-facing wording lives in
# carolus, so it can be changed without republishing a single book. `words` and
# `code` go on the wire as their token, `media` as a JSON object, and
# `code_meta` as its values joined in a fixed order.
#
# The whole block is optional—content with no disclosure is valid, and all four
# wire attributes are simply `nil`. Once the block is present, though, it has to
# be complete and consistent: see `#ai_disclosure_violations`, which is the only
# place that decides whether a disclosure is acceptable. The model validation and
# the pre-publish guard in Runner::Base both read from it, so `robles lint` and
# `robles publish` cannot disagree.
# rubocop:disable Metrics/ModuleLength -- most of the length is the tables of
# permitted values, which are the point of keeping this in one place.
module AiDisclosure
  extend ActiveSupport::Concern

  # Raised by the pre-publish guard, so a bad value never reaches alexandria
  class InvalidDisclosure < StandardError; end

  # The one key authors write. Everything else lives inside it.
  BLOCK_KEY = :ai_disclosure

  # Key inside the block => model attribute, which is also the wire/payload key
  ATTRIBUTE_MAP = {
    words: :ai_words,
    code: :ai_code,
    media: :ai_media,
    code_meta: :ai_code_meta
  }.freeze

  ATTRIBUTES = ATTRIBUTE_MAP.values.freeze

  # Exact, case-sensitive tokens. Anything else is a linting failure.
  PERMITTED_VALUES = {
    words: %w[author_written author_written_ai_edited ai_written_author_edited not_stated].freeze,
    code: %w[author_written ai_assisted ai_generated none not_stated].freeze
  }.freeze

  # `media` is answered per type, because a piece can be author-drawn and
  # AI-voiced at once. A type the piece doesn't have is omitted.
  MEDIA_TYPES = %i[diagrams illustrations voice].freeze
  MEDIA_VALUES = %w[author ai other_human none].freeze

  # `code_meta` is the AI usage detail behind the `code` answer. Values are free
  # text, joined in this order for display.
  CODE_META_KEYS = %i[tokens approximate_cost model date].freeze
  CODE_META_SEPARATOR = ' · '

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

    def inclusion_message(key, value)
      "#{value.inspect} is not a permitted value. Use one of: #{PERMITTED_VALUES.fetch(key).join(', ')}"
    end

    def type_message(value, expected: 'text')
      "must be #{expected}, but was #{value.class} (#{value.inspect})"
    end

    private

    def records_for(subject)
      return subject.sections.flat_map(&:chapters) if subject.respond_to?(:sections)

      Array.wrap(subject)
    end
  end

  included do
    # The block exactly as the author wrote it
    attr_accessor :ai_disclosure
    # Populated by the parser with any disclosure keys written outside the block
    attr_accessor :ai_disclosure_misplaced_keys

    validate :validate_ai_disclosure
  end

  class_methods do
    # Annotations are read by authors, who know the key as `words`, not `ai_words`
    def human_attribute_name(attribute, options = {})
      return 'AI disclosure' if attribute.to_sym == BLOCK_KEY
      return "AI disclosure `#{AiDisclosure.author_key(attribute)}`" if ATTRIBUTES.include?(attribute.to_sym)

      super
    end
  end

  # --- Wire values -----------------------------------------------------------
  # What alexandria stores and carolus reads back. Each is nil when the author
  # didn't answer that part.

  def ai_words
    disclosure[:words]
  end

  def ai_code
    disclosure[:code]
  end

  # A JSON object rather than a token, because the answer is per media type
  def ai_media
    media = disclosure[:media]
    return nil unless media.is_a?(Hash) && media.present?

    JSON.generate(media.slice(*MEDIA_TYPES).transform_keys(&:to_s).transform_values(&:to_s))
  end

  # The values in `CODE_META_KEYS` order, middot-joined. Authors never type the
  # separator, and they can't reorder or invent segments.
  def ai_code_meta
    fields = disclosure[:code_meta]
    return nil unless fields.is_a?(Hash)

    CODE_META_KEYS.filter_map { |key| fields[key].presence&.to_s&.strip.presence }
                  .join(CODE_META_SEPARATOR).presence
  end

  # --- Validation ------------------------------------------------------------

  # Every disclosure problem with this record, as [attribute, message] pairs
  def ai_disclosure_violations
    return misplaced_key_violations if ai_disclosure.nil?
    return block_type_violations unless ai_disclosure.is_a?(Hash)

    unknown_key_violations + token_violations + media_violations +
      code_meta_violations + misplaced_key_violations
  end

  # Overridden by models that can tell whether the piece contains video
  def ai_disclosure_voice_required?
    false
  end

  private

  def disclosure
    ai_disclosure.is_a?(Hash) ? ai_disclosure : {}
  end

  def validate_ai_disclosure
    ai_disclosure_violations.each { |attribute, message| errors.add(attribute, message) }
  end

  def block_type_violations
    [[BLOCK_KEY, "must be a block of #{ATTRIBUTE_MAP.keys.join(', ')}, but was #{ai_disclosure.class} (#{ai_disclosure.inspect})"]]
  end

  # A YAML key is usually a string the parser has symbolised, but `2: ai` is a
  # perfectly valid thing to type, and linting has to report it rather than crash
  def symbolized_keys(hash)
    hash.keys.map { |key| key.respond_to?(:to_sym) ? key.to_sym : key }
  end

  def unknown_key_violations
    (symbolized_keys(disclosure) - ATTRIBUTE_MAP.keys).map do |key|
      [BLOCK_KEY, "has an unknown key `#{key}`. The block takes #{ATTRIBUTE_MAP.keys.join(', ')}"]
    end
  end

  def token_violations
    PERMITTED_VALUES.keys.flat_map do |key|
      value = disclosure[key]
      next [] if value.nil?
      next [[ATTRIBUTE_MAP.fetch(key), AiDisclosure.type_message(value)]] unless value.is_a?(String)
      next [] if PERMITTED_VALUES.fetch(key).include?(value)

      [[ATTRIBUTE_MAP.fetch(key), AiDisclosure.inclusion_message(key, value)]]
    end
  end

  def media_violations
    media = disclosure[:media]
    return missing_voice_violations if media.nil?
    return [[:ai_media, AiDisclosure.type_message(media, expected: "a block of #{MEDIA_TYPES.join(', ')}")]] unless media.is_a?(Hash)
    return [[:ai_media, "must list at least one of #{MEDIA_TYPES.join(', ')} (omit the key if the piece has no media)"]] if media.empty?

    media_key_violations(media) + media_value_violations(media) + missing_voice_violations
  end

  def media_key_violations(media)
    (symbolized_keys(media) - MEDIA_TYPES).map do |type|
      [:ai_media, "has an unknown media type `#{type}`. Use one of: #{MEDIA_TYPES.join(', ')}"]
    end
  end

  def media_value_violations(media)
    media.slice(*MEDIA_TYPES).filter_map do |type, value|
      next if value.is_a?(String) && MEDIA_VALUES.include?(value)

      [:ai_media, "`#{type}` is #{value.inspect}, which is not a permitted value. Use one of: #{MEDIA_VALUES.join(', ')}"]
    end
  end

  # A video module that discloses anything at all has to say who provided the
  # voice: omission means "the piece doesn't have this", which would be a false
  # statement about a piece that is entirely voice.
  def missing_voice_violations
    return [] unless ai_disclosure_voice_required?
    return [] if disclosure[:media].is_a?(Hash) && disclosure[:media].key?(:voice)

    [[:ai_media, "must include `voice` (#{MEDIA_VALUES.join(', ')}), because this module contains video"]]
  end

  def code_meta_violations
    fields = disclosure[:code_meta]
    return [] if fields.nil?
    return [[:ai_code_meta, AiDisclosure.type_message(fields, expected: "a block of #{CODE_META_KEYS.join(', ')}")]] unless fields.is_a?(Hash)
    return [[:ai_code_meta, "must list at least one of #{CODE_META_KEYS.join(', ')} (omit the key if there is nothing to disclose)"]] if fields.empty?

    code_meta_key_violations(fields) + code_meta_value_violations(fields) + code_meta_consistency_violations
  end

  def code_meta_key_violations(fields)
    (symbolized_keys(fields) - CODE_META_KEYS).map do |key|
      [:ai_code_meta, "has an unknown key `#{key}`. Use one of: #{CODE_META_KEYS.join(', ')}"]
    end
  end

  # Values are free text—anything that reads as a line. A nested block or a list
  # has no sensible rendering, and a blank one would leave a gap on the card.
  def code_meta_value_violations(fields)
    fields.slice(*CODE_META_KEYS).filter_map do |key, value|
      next [:ai_code_meta, "`#{key}` #{AiDisclosure.type_message(value)}"] if value.is_a?(Hash) || value.is_a?(Array)
      next if value.presence&.to_s&.strip.present?

      [:ai_code_meta, "`#{key}` must not be blank (omit the key if there is nothing to disclose)"]
    end
  end

  # `code_meta` describes AI assistance with the code, so it contradicts a `code`
  # answer that says there was none
  def code_meta_consistency_violations
    return [] unless %w[none author_written].include?(disclosure[:code])

    [[:ai_code_meta, "is set, but `code` is `#{disclosure[:code]}`: remove one or the other"]]
  end

  # Keys written outside the block are dropped by the parser, so an author who
  # writes a top-level `words` would otherwise publish nothing with no warning
  def misplaced_key_violations
    Array.wrap(ai_disclosure_misplaced_keys).filter_map do |key|
      attribute = ATTRIBUTE_MAP[key.to_sym] || (ATTRIBUTES.include?(key.to_sym) ? key.to_sym : nil)
      next if attribute.nil?

      [attribute, "was written at the top level as `#{key}`: nest it inside the `#{BLOCK_KEY}` block"]
    end
  end

  # Defaults for the serialisation allow-list, to be merged into `#attributes`
  def ai_disclosure_defaults
    ATTRIBUTES.index_with(nil).stringify_keys
  end
end
# rubocop:enable Metrics/ModuleLength
