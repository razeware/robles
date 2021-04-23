# frozen_string_literal: true

module Renderer
  # Methods that make it possible to determine image attributes
  module ImageAttributes
    VALID_MODIFIERS = %w[bordered iphone iphone-landscape ipad ipad-landscape tvos watch bezel float-left float-right].freeze

    attr_reader :image_provider

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
                    .filter { |r| ImageRepresentation::DEFAULT_WIDTHS.keys.include?(r.variant) }
                    .uniq(&:variant)
    end

    def class_list(alt_text)
      (display_classes(alt_text) << width_class(alt_text)).join(' ')
    end

    def display_classes(alt_text)
      alt_text.split(' ')
              .intersection(VALID_MODIFIERS)
              .map { |modifier| "l-image-#{modifier}" }
    end

    def width_class(alt_text)
      width_match = /width=(\d+)%/.match(alt_text)
      return if width_match.blank?

      # Convert width request to a class that's a multiple of 10
      width = width_match[1].to_i.round(-1).clamp(0, 100)
      "l-image-#{width}"
    end

    # Importing SVGs directly inline
    def svg_url(relative_url)
      relative_svg_url = relative_url.gsub(Pathname(relative_url).extname, '.svg')
      "#{root_path}/#{relative_svg_url}"
    end

    def svg?(alt_text, relative_url)
      alt_text.split(' ').include?('svg') && Pathname(svg_url(relative_url)).exist?
    end

    def svg_content(relative_url)
      File.read(svg_url(relative_url))
    end
  end
end
