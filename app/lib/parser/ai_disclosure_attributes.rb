# frozen_string_literal: true

module Parser
  # Hands the author's `ai_disclosure` block to the model, which is where every
  # decision about its contents is made.
  #
  # Expects the including parser to expose a symbolised `metadata` hash.
  module AiDisclosureAttributes
    def ai_disclosure_attributes
      {
        ai_disclosure: metadata[::AiDisclosure::BLOCK_KEY],
        ai_disclosure_misplaced_keys: misplaced_disclosure_keys
      }
    end

    private

    # Disclosure keys written at the top level instead of inside the block are
    # not read by anything: they are handed to the model, which turns them into a
    # linting failure rather than letting the author publish nothing in silence.
    def misplaced_disclosure_keys
      keys = metadata.keys.map(&:to_sym)

      (keys & ::AiDisclosure::ATTRIBUTE_MAP.keys) | (keys & ::AiDisclosure::ATTRIBUTES)
    end
  end
end
