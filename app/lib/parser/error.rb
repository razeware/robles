# frozen_string_literal: true

module Parser
  # An error for capturing parsing issues
  class Error < StandardError
    attr_reader :file

    def initialize(file:, error: nil, msg: nil)
      message = "There was a problem parsing #{file}"
      message += "\n#{error.class.name}\n#{error.message}" if error.present?
      message += "\n#{msg}" if msg.present?

      super(message)
      @file = file
    end
  end
end
