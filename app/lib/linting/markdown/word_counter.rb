# frozen_string_literal: true

module Linting
  module Markdown
    class WordCounter
      attr_reader :markdown, :doc

      def initialize(markdown)
        @markdown = markdown
        @doc = CommonMarker.render_doc(markdown)
      end

      def count
        @count ||= doc.walk
                      .filter { %i[text code].include?(_1.type) }
                      .map(&:string_content)
                      .join
                      .scan(/\S+/)
                      .size
      end
    end
  end
end
