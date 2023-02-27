# frozen_string_literal: true

module ImageProvider
  # Takes a markdown file, and returns all the images URLs
  class MarkdownImageExtractor
    include Util::PathExtraction

    def self.images_from(file)
      new(file:).images
    end

    def images
      [].tap do |images|
        doc.walk do |node|
          next unless node.type == :image

          alt_text = node.each.select { |child| child.type == :text }.map(&:string_content).join(' ')
          images << image_record(node.url, alt_text)
        end
      end
    end

    def image_record(url, alt_text)
      {
        relative_path: cleanpath(url),
        absolute_path: cleanpath(apply_path(url)),
        alt_text:,
        variants: ImageRepresentation::DEFAULT_WIDTHS.keys
      }
    end

    def cleanpath(path)
      Pathname.new(path).cleanpath.to_s
    end

    def doc
      @doc ||= CommonMarker.render_doc(markdown)
    end

    def markdown
      @markdown ||= File.read(file)
    end
  end
end
