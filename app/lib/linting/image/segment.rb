# frozen_string_literal: true

module Linting
  module Image
    # Lint the images associated with a segment
    class Segment
      include Linting::Image::Attachable
      include Linting::Image::Markdown

      def self.lint(segment)
        new(segment).lint
      end

      def lint
        [].tap do |annotations|
          annotations.concat(lint_attachments) if object.class < Concerns::ImageAttachable
          annotations.concat(lint_markdown_images(check_width: false)) if markdown_file.present?
        end
      end

      def markdown_file
        case segment_type
        when 'video'
          object.script_file
        when 'text'
          object.markdown_file
        else
          nil
        end
      end

      # What is the segment type
      def segment_type
        object.class.name.demodulize.underscore
      end
    end
  end
end
