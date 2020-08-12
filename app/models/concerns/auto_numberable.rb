# frozen_string_literal: true

module Concerns
  # Adds a method to assist with auto numbering of objects
  module AutoNumberable
    extend ActiveSupport::Concern

    included do
      attr_accessor :number
    end

    # Takes the number of the previous object, and returns the new, updated one
    def auto_number(index)
      return number.to_i unless number == 'auto'

      new_index = index + 1
      self.number = new_index.to_s
      new_index
    end
  end
end
