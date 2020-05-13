# frozen_string_literal: true

module Parser
  # Parses the metadata at the top of a markdown file
  module MarkdownMetadata
    START_DELIMITER = '```metadata'
    END_DELIMITER   = '```'

    attr_reader :path

    def extract_metadata # rubocop:disable Metrics/MethodLength
      [].tap do |metadata_lines|
        metadata_found = false
        IO.foreach(path) do |line|
          # Remove trailing whitespace
          line.chomp!
          # Are we still searching for the metadata section?
          if !metadata_found
            # Have we found the start?
            metadata_found = (line == START_DELIMITER)
          else
            # Have we reached the end?
            break if line == END_DELIMITER

            # Otherwise this line is part of the metadata section
            metadata_lines << line
          end
        end
      end.join("\n")
    end

    def metadata
      @metadata ||= Psych.load(extract_metadata).deep_symbolize_keys
    end

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
