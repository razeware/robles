# frozen_string_literal: true

module Parser
  # Maps the author-facing AI disclosure keys (`words`, `code`, `media`,
  # `code_meta`) from a metadata hash onto the `ai_`-prefixed model attributes.
  #
  # Expects the including parser to expose a symbolised `metadata` hash.
  module AiDisclosureAttributes
    def ai_disclosure_attributes
      metadata.slice(*::AiDisclosure::ATTRIBUTE_MAP.keys)
              .transform_keys(::AiDisclosure::ATTRIBUTE_MAP)
              .merge(ai_disclosure_unknown_keys: prefixed_disclosure_keys)
    end

    private

    # `ai_words` and friends are wire names, not author-facing ones: they are not
    # in the slice above, so they would be dropped in silence. Hand them to the
    # model instead, which turns them into a linting failure.
    def prefixed_disclosure_keys
      metadata.keys.map(&:to_sym) & ::AiDisclosure::ATTRIBUTES
    end
  end
end
