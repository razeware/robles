# frozen_string_literal: true

module Linting
  module Markdown
    # Check that the attributes marked as markdown renderable are valid
    module Renderable
      WORD_LIMIT = 4000

      include Linting::FileExistenceChecker

      attr_reader :object

      def initialize(object)
        @object = object
      end

      def lint_markdown_attributes
        [].tap do |annotations|
          object.markdown_render_loop do |content, is_file|
            markdown = is_file ? File.read(content) : content
            
            if is_file
              counter = Linting::Markdown::WordCounter.new(markdown)
              annotations << word_count_annotation(content, counter.count) if counter.count > WORD_LIMIT
            end
          end
        end
      end

      def word_count_annotation(file, word_count)
        Linting::Annotation.new(
          start_line: 0,
          end_line: 0,
          absolute_path: file,
          annotation_level: 'warning',
          message: "The word count in #{Pathname.new(file).basename} is #{word_count}. This exceeds the allowable limit of #{WORD_LIMIT}",
          title: "Word limit exceeded in #{Pathname.new(file).basename}"
        )
      end
    end
  end
end
