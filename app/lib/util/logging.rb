# frozen_string_literal: true

module Util
  # Makes a logger available via class and instance variables
  module Logging
    extend ActiveSupport::Concern

    included do
      class_attribute :logger, instance_writer: false, default: Logger.new(STDOUT)
    end
  end
end
