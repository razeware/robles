# frozen_string_literal: true

module Linting
  module Markdown
    class WordCounter
      WORD_LIMIT = 4000

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

      def exceeds_word_limit?
        count > WORD_LIMIT
      end
    end
  end
end
