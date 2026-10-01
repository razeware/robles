# frozen_string_literal: true

require 'tmpdir'
require_relative '../test_helper'

module ImageProvider
  # Characterisation tests for the extractor that decides which images get
  # resized and uploaded. Missing an image here means a broken image on the
  # published site, so the assertions cover every shape the corpus uses.
  class MarkdownImageExtractorTest < Minitest::Test
    include TestHelpers

    def extract(markdown)
      Dir.mktmpdir do |dir|
        path = File.join(dir, 'body.md')
        File.write(path, markdown)
        MarkdownImageExtractor.images_from(path).map { |image| image.slice(:relative_path, :alt_text) }
      end
    end

    def test_extracts_every_image_in_the_corpus
      images = MarkdownImageExtractor.images_from(fixture_path('markdown/images.md'))

      assert_equal(
        [
          ['assets/screenshot.png', 'width=50%'],
          ['assets/screenshot.png', 'width=33%'],
          ['assets/screenshot.png', 'width=100% bordered float-left'],
          ['assets/screenshot.png', 'width=47%'],
          ['assets/screenshot.png', 'portrait iphone'],
          ['assets/diagram.png', 'svg width=60%'],
          ['assets/animation.gif', 'width=80%'],
          ['assets/screenshot.png', 'just alt text']
        ],
        images.map { |image| [image[:relative_path], image[:alt_text]] }
      )
    end

    def test_records_absolute_paths_and_the_default_variants
      Dir.mktmpdir do |dir|
        path = File.join(dir, 'body.md')
        File.write(path, "![width=50%](../shared/shot.png)\n")
        image = MarkdownImageExtractor.images_from(path).first

        assert_equal '../shared/shot.png', image[:relative_path]
        assert_equal File.expand_path(File.join(dir, '..', 'shared', 'shot.png')), image[:absolute_path]
        assert_equal ImageRepresentation::DEFAULT_WIDTHS.keys, image[:variants]
      end
    end

    def test_ignores_links_that_are_not_images
      assert_empty extract("[not an image](assets/shot.png)\n")
    end

    def test_finds_images_nested_in_other_blocks
      markdown = <<~MD
        - ![width=50%](assets/in-a-list.png)

        > ![width=50%](assets/in-a-quote.png)

        | A |
        | - |
        | ![width=50%](assets/in-a-table.png) |
      MD

      assert_equal(
        %w[assets/in-a-list.png assets/in-a-quote.png assets/in-a-table.png],
        extract(markdown).map { |image| image[:relative_path] }
      )
    end
  end
end
