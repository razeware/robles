# frozen_string_literal: true

module Renderer
  # Custom implementation of a markdown renderer for RW books
  class RWMarkdownRenderer < Redcarpet::Render::HTML
    include Redcarpet::Render::SmartyPants
    include Parser::FrontmatterMetadataFinder
    include Renderer::ImageAttributes

    attr_reader :root_path

    def initialize(attributes = {})
      super
      @image_provider = attributes[:image_provider]
      @root_path = attributes[:root_path]
    end

    def image(link, title, alt_text)
      return %(<img src="#{link}" alt="#{alt_text}" title="#{title}" />) if image_provider.blank?

      %(
        <figure title="#{title}" class="#{class_list(alt_text)}">
          <img src="#{src(link)}" srcset="#{srcset(link)}" alt="#{title}" title="#{title}" />
          <figcaption>#{title}</figcaption>
        </figure>
      )
    end

    def preprocess(full_document)
      removing_pagesetting_notation = full_document.gsub(/\$\[=[=sp]=\]/, '')
      without_metadata(removing_pagesetting_notation.each_line)
    end
  end
end
