# frozen_string_literal: true

module Linting
  module Markdown
    # Check that the attributes marked as markdown renderable are valid
    module Renderable
      include Linting::FileExistenceChecker

      attr_reader :object

      def initialize(object)
        @object = object
      end

      def lint_markdown_attributes
        object.markdown_render_loop do |content, is_file|
          markdown = is_file ? File.read(content) : content
          # TODO: Do some checking here
          content
        end
        []
      end
    end
  end
end
