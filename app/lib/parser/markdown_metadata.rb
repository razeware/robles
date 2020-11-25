# frozen_string_literal: true

module Parser
  # Parses the metadata at the top of a markdown file
  module MarkdownMetadata
    include Parser::FrontmatterMetadataFinder
    include Parser::SimpleAttributes

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
  end
end
