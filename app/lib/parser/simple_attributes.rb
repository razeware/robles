# frozen_string_literal: true

module Parser
  # Specifies and validates existence of simple attributes
  module SimpleAttributes
    def simple_attributes
      @simple_attributes ||= metadata.slice(*valid_simple_attributes)
                                     .assert_valid_keys(*valid_simple_attributes)
    end

    private

    def valid_simple_attributes
      self.class.const_get(:VALID_SIMPLE_ATTRIBUTES)
    end
  end
end
