# frozen_string_literal: true

module Parser
  # Parses a publish.yaml file, and returns a Book model object
  class Publish
    include Util::PathExtraction

    VALID_BOOK_ATTRIBUTES = %i[sku edition title description released_at materials_url
                               cover_image gallery_image twitter_card_image trailer_video_url
                               version_description professional difficulty platform
                               language editor domains categories who_is_this_for_md
                               covered_concepts_md hide_chapter_numbers in_flux].freeze

    attr_reader :book

    def parse
      load_book_segments
      apply_additonal_metadata
      update_authors_on_chapters
      book
    end

    def load_book_segments
      @book = Parser::BookSegments.new(file: file).parse
    end

    def apply_additonal_metadata
      book.assign_attributes(additional_attributes)
      book.root_path = root_directory
    end

    def update_authors_on_chapters
      book.sections.each do |section|
        section.chapters.each do |chapter|
          chapter.authors += authors
        end
      end
    end

    private

    def publish_file
      @publish_file ||= Psych.load_file(file).deep_symbolize_keys
    end

    def authors
      @authors = publish_file[:authors].map do |author|
        Author.new(author)
      end
    end

    def additional_attributes
      @additional_attributes ||= publish_file.slice(*VALID_BOOK_ATTRIBUTES)
                                             .assert_valid_keys(*VALID_BOOK_ATTRIBUTES)
    end
  end
end
