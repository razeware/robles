# frozen_string_literal: true

module Renderer
  # Custom implementation of a markdown renderer for RW books
  class RWMarkdownRenderer < Redcarpet::Render::HTML
    include Redcarpet::Render::SmartyPants
    include Parser::FrontmatterMetadataFinder
    include Renderer::ImageAttributes
    include Util::Logging

    attr_reader :root_path

    def initialize(attributes = {})
      logger.debug 'RWMarkdownRenderer::initialize'
      super
      @image_provider = attributes[:image_provider]
      @root_path = attributes[:root_path]
    end

    def image(link, title, alt_text)
      return %(<img src="#{link}" alt="#{alt_text}" title="#{title}" />) if image_provider.blank?

      %(
        <figure title="#{title}" class="#{class_list(alt_text)}">
          <picture>
            <img src="#{src(link)}" alt="#{title}" title="#{title}">
            <source srcset="#{srcset(link)}">
          </picture>
          <figcaption>#{title}</figcaption>
        </figure>
      )
    end

    def preprocess(full_document)
      logger.debug 'RWMarkdownRenderer::preprocess'
      removing_pagesetting_notation = full_document.gsub(/\$\[=[=sp]=\]/, '')
      without_metadata(removing_pagesetting_notation.each_line)
    end
  end
end
