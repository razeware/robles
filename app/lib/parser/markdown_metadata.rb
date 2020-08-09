# frozen_string_literal: true

module Parser
  # Parses the metadata at the top of a markdown file
  module MarkdownMetadata
    include Parser::FrontmatterMetadataFinder

    attr_reader :path

    def extract_metadata
      find_metadata(IO.foreach(path))
    end

    def metadata
      @metadata ||= begin
        Psych.load(extract_metadata, symbolize_names: true).tap do |metadata|
          raise Parser::Error.new(file: path, msg: 'Unable to locate metadata at the top of the markdown') unless metadata.present?
        end
      end
    rescue Psych::SyntaxError => e
      raise Parser::Error.new(file: path, error: e)
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
