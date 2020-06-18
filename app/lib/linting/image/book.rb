# frozen_string_literal: true

module Linting
  module Image
    # Lint the image associated with a book
    class Book
      include Linting::Image::Attachable

      def self.lint(book)
        new(book).lint
      end

      def lint
        [].tap do |annotations|
          annotations.concat(lint_attachments)
          object.sections.each do |section|
            annotations.concat(Linting::Image::Section.lint(section))
          end
        end
      end
    end
  end
end
