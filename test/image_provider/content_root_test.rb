# frozen_string_literal: true

require 'fileutils'
require 'tmpdir'
require_relative '../test_helper'

module ImageProvider
  # Every image a book, module or video course publishes has to be a regular
  # file inside its own root directory. Anything else stops the publish before
  # an image is read or uploaded. The content is built in a temp dir, and the
  # tests make their own symlinks there rather than committing them.
  class ContentRootTest < Minitest::Test
    # The ../ path stays inside the root, and linked.png is a symlink that does
    INSIDE_MARKDOWN = <<~MD
      ![width=50%](images/shot.png)
      ![width=50%](../shared/logo.png)
      ![width=50%](images/linked.png)
    MD

    def setup
      @dir = Dir.mktmpdir
      @root = File.join(@dir, 'content')
      @outside = File.join(@dir, 'outside')
      FileUtils.mkdir_p([File.join(@root, 'lesson', 'images'), File.join(@root, 'shared'), @outside])
      [File.join(@root, 'lesson', 'images', 'shot.png'), File.join(@root, 'shared', 'logo.png'),
       File.join(@root, 'cover.png'), File.join(@outside, 'stray.png'), File.join(@outside, 'notes.txt')].each do |file|
        File.write(file, 'not really an image')
      end
    end

    def teardown
      FileUtils.remove_entry(@dir)
    end

    def link(target, name)
      File.symlink(target, File.join(@root, 'lesson', 'images', name))
    end

    def write_markdown(markdown)
      File.join(@root, 'lesson', 'body.md').tap { |file| File.write(file, markdown) }
    end

    def book(markdown, cover_image: 'cover.png')
      chapter_file = write_markdown(markdown)
      section_file = File.join(@root, 'section.md').tap { |file| File.write(file, "# Section\n") }
      chapter = ::Chapter.new(markdown_file: chapter_file, root_path: File.dirname(chapter_file))
      section = ::Section.new(markdown_file: section_file, chapters: [chapter], root_path: @root)
      ::Book.new(sections: [section], root_path: Pathname.new(@root), cover_image:)
    end

    def content_module(markdown, featured_banner_image: 'cover.png')
      text_file = write_markdown(markdown)
      text = ::Text.new(markdown_file: text_file, root_path: File.dirname(text_file))
      ::ContentModule.new(lessons: [::Lesson.new(segments: [text])], root_path: Pathname.new(@root), featured_banner_image:)
    end

    def video_course(card_artwork_image)
      ::VideoCourse.new(root_path: Pathname.new(@root), card_artwork_image:)
    end

    def assert_refused(extractor, relative_path)
      error = assert_raises(Util::ContentPath::InvalidPath) { extractor.extract }

      assert_includes error.message, "image #{relative_path} isn't a regular file inside #{@root}"
      error
    end

    def inside_paths
      [File.join(@root, 'cover.png'), File.join(@root, 'lesson', 'images', 'linked.png'),
       File.join(@root, 'lesson', 'images', 'shot.png'), File.join(@root, 'shared', 'logo.png')]
    end

    def test_a_book_publishes_images_inside_its_root_including_symlinks_that_stay_inside
      link('../../shared/logo.png', 'linked.png')

      assert_equal inside_paths, BookExtractor.new(book(INSIDE_MARKDOWN)).extract.map(&:local_url).sort
    end

    def test_a_book_image_reached_by_dot_dot_from_outside_the_root_stops_the_publish
      assert_refused(BookExtractor.new(book("![width=50%](../../outside/stray.png)\n")), '../outside/stray.png')
    end

    def test_a_symlinked_book_gif_leading_out_of_the_root_stops_the_publish
      link(File.join(@outside, 'notes.txt'), 'animation.gif')
      error = assert_refused(BookExtractor.new(book("![width=50%](images/animation.gif)\n")), 'lesson/images/animation.gif')

      refute_includes error.message, 'notes.txt'
    end

    def test_a_book_cover_outside_the_root_stops_the_publish
      assert_refused(BookExtractor.new(book("No images.\n", cover_image: '../outside/stray.png')), '../outside/stray.png')
    end

    def test_a_module_publishes_images_inside_its_root_including_symlinks_that_stay_inside
      link('../../shared/logo.png', 'linked.png')

      assert_equal inside_paths, ContentModuleExtractor.new(content_module(INSIDE_MARKDOWN)).extract.map(&:local_url).sort
    end

    def test_a_module_image_reached_by_dot_dot_from_outside_the_root_stops_the_publish
      assert_refused(ContentModuleExtractor.new(content_module("![width=50%](../../outside/stray.png)\n")), '../outside/stray.png')
    end

    def test_a_symlinked_module_gif_leading_out_of_the_root_stops_the_publish
      link(File.join(@outside, 'notes.txt'), 'animation.gif')
      error = assert_refused(ContentModuleExtractor.new(content_module("![width=50%](images/animation.gif)\n")), 'lesson/images/animation.gif')

      refute_includes error.message, 'notes.txt'
    end

    def test_a_module_image_that_is_not_a_regular_file_stops_the_publish
      FileUtils.mkdir_p(File.join(@root, 'lesson', 'images', 'folder.png'))

      assert_refused(ContentModuleExtractor.new(content_module("![width=50%](images/folder.png)\n")), 'lesson/images/folder.png')
    end

    def test_a_module_banner_symlinked_out_of_the_root_stops_the_publish
      File.symlink(File.join(@outside, 'stray.png'), File.join(@root, 'banner.png'))

      assert_refused(ContentModuleExtractor.new(content_module("No images.\n", featured_banner_image: 'banner.png')), 'banner.png')
    end

    def test_a_video_course_publishes_artwork_inside_its_root
      assert_equal [File.join(@root, 'cover.png')], VideoCourseExtractor.new(video_course('cover.png')).extract.map(&:local_url)
    end

    def test_video_course_artwork_outside_the_root_stops_the_publish
      assert_refused(VideoCourseExtractor.new(video_course('../outside/stray.png')), '../outside/stray.png')
    end
  end
end
