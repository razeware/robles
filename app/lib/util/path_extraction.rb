# frozen_string_literal: true

module Util
  # Apply relative path to the file attribute
  module PathExtraction
    attr_reader :file

    def initialize(file:)
      @file = file
    end

    def apply_path(path)
      (root_directory + path).to_s
    end

    def root_directory
      @root_directory ||= Pathname.new(file).dirname
    end
  end
end
