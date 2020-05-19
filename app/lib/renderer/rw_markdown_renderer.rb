# frozen_string_literal: true

module Renderer
  # Custom implementation of a markdown renderer for RW books
  class RWMarkdownRenderer < Redcarpet::Render::HTML
    include Redcarpet::Render::SmartyPants

    attr_reader :image_provider, :root_path

    def initialize(attributes = {})
      super
      @image_provider = attributes[:image_provider]
      @root_path = attributes[:root_path]
    end

    def image(link, title, alt_text)
      return super if image_provider.blank?

      %(<img src="#{src(link)}" srcset="#{srcset(link)}" alt="#{alt_text}" title="#{title}" />)
    end

    def srcset(relative_url)
      representations("#{root_path}/#{relative_url}").filter { |r| r.width != :original }
                                                     .map { |r| "#{r.remote_url} #{r.width_px}w" }
                                                     .join(', ')
    end

    def src(relative_url)
      representations("#{root_path}/#{relative_url}").find { |r| r.width == :original }.remote_url
    end

    def representations(local_url)
      image_provider.representations_for_local_url(local_url)
    end
  end
end
