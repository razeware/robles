# frozen_string_literal: true

module Parser
  # Parses the metadata at the top of a markdown file
  module MarkdownMetadata
    include Parser::FrontmatterMetadataFinder
    include Parser::SimpleAttributes

    attr_reader :path

    def extract_metadata
      find_metadata(File.foreach(path))
    end

    def metadata
      # If we've provided a metadata hash, then use that as well
      (@metadata || {}).merge(markdown_metadata || {})
    end

    def markdown_metadata
      return {} if path.blank?

      @markdown_metadata ||= load_yaml(extract_metadata).tap do |header_metadata|
        # If can't metadata, and also don't have a provided hash, then raise error
        raise Parser::Error.new(file: path, msg: 'Unable to locate metadata at the top of the markdown') if header_metadata.blank? && @metadata.blank?
      end || {}
    rescue Psych::SyntaxError => e
      raise Parser::Error.new(file: path, error: e)
    end

    def load_yaml(file)
      Psych.load(file, symbolize_names: true, permitted_classes: [Date])
    end
  end
end
