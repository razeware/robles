# frozen_string_literal: true

require 'fileutils'
require 'tmpdir'
require_relative '../test_helper'

module Parser
  # Every file a book, module or video course reads, not only its images, has to
  # be a regular file inside its own root. Anything else stops the parse, and so
  # the publish, lint and preview, with an error against the file that names the
  # path. The error names the path as written, never a symlink's target. The
  # content is built in a temp dir, and the tests make their own symlinks there
  # rather than committing them.
  class ContentRootTest < Minitest::Test
    include TestHelpers

    MODULE_LINT_OPTIONS = { 'silent' => true, 'without-version' => true }.freeze
    BOOK_LINT_OPTIONS = { 'silent' => true, 'without-edition' => true }.freeze

    # The rest of what the book linter needs in publish.yaml before it parses
    BOOK_METADATA = {
      edition: 1, description_md: 'A test book.', short_description: 'A test book.', released_at: '2026-09-01',
      authors: [{ username: 'author', role: 'author' }], materials_url: 'https://example.com/materials',
      cover_image: 'cover.png', version_description: 'First edition', difficulty: 'beginner',
      platform: 'iOS 18', language: 'Swift 6', editor: 'Xcode 16'
    }.freeze

    def setup
      @dir = Dir.mktmpdir
      @root = File.join(@dir, 'content')
      FileUtils.mkdir_p(@root)
      # Every symlink out of the root points here, so no error may mention it
      @target = write('../outside/linked-target.txt', "Placeholder text outside the root\n")
    end

    def teardown
      FileUtils.remove_entry(@dir)
    end

    # Writes a file at a path relative to the root, or at an absolute path
    def write(path, content)
      File.expand_path(path, @root).tap do |file|
        FileUtils.mkdir_p(File.dirname(file))
        File.write(file, content)
      end
    end

    # Makes `path`, relative to the root, a symlink to `target`
    def link(path, target = @target)
      File.join(@root, path).tap do |file|
        FileUtils.mkdir_p(File.dirname(file))
        File.symlink(target, file)
      end
    end

    def markdown(title, captions_file: nil)
      captions = "captions_file: #{captions_file}\n" if captions_file
      "```metadata\ntitle: #{title}\n#{captions}```\n\nPlaceholder text.\n"
    end

    # Parsing records the git hash, so the content needs a commit
    def commit(remote: nil)
      repo = Git.init(@root)
      repo.remote_add('origin', remote) if remote
      repo.config_set('user.name', 'robles test')
      repo.config_set('user.email', 'robles-test@example.com')
      repo.add(all: true)
      repo.commit('Fixture')
    end

    # A book with a section and a chapter at the segment paths given
    def book(section: 'sections/01.md', chapter: 'chapters/01.md', **metadata)
      write('sections/01.md', markdown('Section One'))
      write('chapters/01.md', markdown('Chapter One'))
      segments = [{ kind: 'section', path: section }, { kind: 'chapter', path: chapter }]
      write('publish.yaml', { sku: 'test-book', title: 'Test Book', segments: }.merge(metadata).deep_stringify_keys.to_yaml)
    end

    def parse_book
      commit
      Parser::Publish.new(file: File.join(@root, 'publish.yaml')).parse
    end

    # A module with one lesson holding the segments given
    def content_module(*segments, segments_path: 'lessons/01/lesson.yaml')
      write(segments_path, { 'title' => 'Lesson One', 'segments' => segments }.to_yaml)
      write('module.yaml', { 'shortcode' => 'test-module', 'title' => 'Test Module', 'lessons' => [{ 'segments_path' => segments_path }] }.to_yaml)
    end

    def segment(path, type)
      { 'path' => path, 'type' => type }
    end

    def parse_module
      commit
      Parser::Circulate.new(file: File.join(@root, 'module.yaml')).parse
    end

    # A video course with one part holding one episode
    def video_course(episode)
      part = { 'title' => 'Part One', 'episodes' => [{ 'title' => 'Episode One' }.merge(episode)] }
      write('release.yaml', { 'shortcode' => 'test-course', 'title' => 'Test Course', 'parts' => [part] }.to_yaml)
    end

    def parse_course
      commit
      Parser::Release.new(file: File.join(@root, 'release.yaml')).parse
    end

    def assert_refused(refused, named_in:, &)
      error = assert_raises(Parser::Error, &)

      assert_includes error.message, "Refusing to publish: #{refused} isn't a regular file inside #{@root}."
      assert_equal File.join(@root, named_in), error.file.to_s
      refute_includes error.message, 'linked-target'
    end

    def assert_parse_failure(output, title, path:, refused:)
      annotation = output.annotations.find { _1.title == title }

      refute output.validated
      assert_equal ['failure', path], [annotation.annotation_level, annotation.path]
      assert_includes annotation.message, "Refusing to publish: #{refused} isn't a regular file inside #{@root}."
      refute_includes annotation.message, 'linked-target'
    end

    def image_paths(book)
      ImageProvider::BookExtractor.new(book).extract.map(&:local_url)
    end

    # Books

    def test_a_chapter_symlinked_out_of_the_root_stops_the_parse
      link('chapters/02.md')
      book(chapter: 'chapters/02.md')

      assert_refused('chapter chapters/02.md', named_in: 'publish.yaml') { parse_book }
    end

    def test_a_section_symlinked_out_of_the_root_stops_the_parse
      link('sections/02.md')
      book(section: 'sections/02.md')

      assert_refused('section sections/02.md', named_in: 'publish.yaml') { parse_book }
    end

    def test_a_chapter_reached_by_dot_dot_from_outside_the_root_stops_the_parse
      write('../outside/stray.md', markdown('Stray Chapter'))
      book(chapter: '../outside/stray.md')

      assert_refused('chapter ../outside/stray.md', named_in: 'publish.yaml') { parse_book }
    end

    # Named relative to the root, as WEB-7818 names images
    def test_a_chapter_reached_by_an_absolute_path_stops_the_parse
      book(chapter: write('../outside/stray.md', markdown('Stray Chapter')))

      assert_refused('chapter ../outside/stray.md', named_in: 'publish.yaml') { parse_book }
    end

    def test_a_manifest_outside_the_root_stops_the_parse
      write('../outside/manifest.yaml', { 'title' => 'Stray Book', 'segments' => [] }.to_yaml)
      book(manifest_file: '../outside/manifest.yaml')

      assert_refused('manifest ../outside/manifest.yaml', named_in: 'publish.yaml') { parse_book }
    end

    def test_a_symlinked_vend_file_stops_the_parse
      link('vend.yaml')
      book

      assert_refused('vend file vend.yaml', named_in: 'publish.yaml') { parse_book }
    end

    # Paths stay as written, so a chapter's images resolve from the symlink's
    # directory, not from the directory of the file it points at
    def test_a_chapter_symlinked_to_a_file_inside_the_book_still_parses
      write('shared/chapter.md', "#{markdown('Shared Chapter')}\n![width=50%](images/shot.png)\n")
      write('chapters/images/shot.png', 'not really an image')
      link('chapters/02.md', '../shared/chapter.md')
      book(chapter: 'chapters/02.md')
      parsed = parse_book

      assert_equal File.join(@root, 'chapters'), parsed.sections.first.chapters.first.root_path
      assert_includes image_paths(parsed), File.join(@root, 'chapters/images/shot.png')
    end

    # Modules

    def test_a_lesson_reached_by_dot_dot_from_outside_the_root_stops_the_parse
      content_module(segments_path: '../outside/lesson.yaml')

      assert_refused('lesson file ../outside/lesson.yaml', named_in: 'module.yaml') { parse_module }
    end

    def test_a_text_symlinked_out_of_the_root_stops_the_parse
      link('lessons/01/01-text.md')
      content_module(segment('01-text.md', 'text'))

      assert_refused('text lessons/01/01-text.md', named_in: 'lessons/01/lesson.yaml') { parse_module }
    end

    def test_a_module_script_symlinked_out_of_the_root_stops_the_parse
      link('lessons/01/02-video.md')
      content_module(segment('02-video.md', 'video'))

      assert_refused('script lessons/01/02-video.md', named_in: 'lessons/01/lesson.yaml') { parse_module }
    end

    def test_a_module_assessment_symlinked_out_of_the_root_stops_the_parse
      link('lessons/01/03-quiz.yaml')
      content_module(segment('03-quiz.yaml', 'assessment'))

      assert_refused('assessment lessons/01/03-quiz.yaml', named_in: 'lessons/01/lesson.yaml') { parse_module }
    end

    def test_captions_named_in_a_script_that_lead_out_of_the_root_stop_the_parse
      write('../outside/captions.vtt', "WEBVTT\n")
      write('lessons/01/02-video.md', markdown('Video One', captions_file: '../../../outside/captions.vtt'))
      content_module(segment('02-video.md', 'video'))

      assert_refused('captions file ../outside/captions.vtt', named_in: 'lessons/01/02-video.md') { parse_module }
    end

    def test_a_missing_module_script_still_stops_the_parse
      content_module(segment('02-missing.md', 'video'))

      assert_refused('script lessons/01/02-missing.md', named_in: 'lessons/01/lesson.yaml') { parse_module }
    end

    def test_a_module_with_its_files_inside_the_root_parses_as_before
      write('lessons/01/01-text.md', markdown('Text One'))
      write('lessons/01/02-video.md', markdown('Video One', captions_file: 'captions.vtt'))
      write('lessons/01/captions.vtt', "WEBVTT\n")
      content_module(segment('01-text.md', 'text'), segment('02-video.md', 'video'))
      text, video = parse_module.lessons.first.segments

      assert_equal File.join(@root, 'lessons/01/01-text.md'), text.markdown_file
      assert_equal File.join(@root, 'lessons/01/captions.vtt'), video.captions_file
    end

    # Video courses

    def test_a_course_script_symlinked_out_of_the_root_stops_the_parse
      link('scripts/01.md')
      video_course('script_file' => 'scripts/01.md')

      assert_refused('script scripts/01.md', named_in: 'release.yaml') { parse_course }
    end

    def test_course_captions_symlinked_out_of_the_root_stop_the_parse
      write('scripts/01.md', "Placeholder script.\n")
      link('captions/01.vtt')
      video_course('script_file' => 'scripts/01.md', 'captions_file' => 'captions/01.vtt')

      assert_refused('captions file captions/01.vtt', named_in: 'release.yaml') { parse_course }
    end

    def test_a_course_assessment_reached_by_dot_dot_from_outside_the_root_stops_the_parse
      write('../outside/quiz.yaml', { 'assessment_type' => 'quiz', 'questions' => [] }.to_yaml)
      video_course('assessment_file' => '../outside/quiz.yaml')

      assert_refused('assessment ../outside/quiz.yaml', named_in: 'release.yaml') { parse_course }
    end

    def test_missing_course_captions_still_stop_the_parse
      write('scripts/01.md', "Placeholder script.\n")
      video_course('script_file' => 'scripts/01.md', 'captions_file' => 'captions/missing.vtt')

      assert_refused('captions file captions/missing.vtt', named_in: 'release.yaml') { parse_course }
    end

    def test_a_course_with_its_files_inside_the_root_parses_as_before
      write('scripts/01.md', "Placeholder script.\n")
      write('captions/01.vtt', "WEBVTT\n")
      video_course('script_file' => 'scripts/01.md', 'captions_file' => 'captions/01.vtt')
      video = parse_course.parts.first.episodes.first

      assert_equal File.join(@root, 'scripts/01.md'), video.script_file
      assert_equal File.join(@root, 'captions/01.vtt'), video.captions_file
    end

    # Linters: the parse stage reports these as failures rather than crashing

    def test_the_module_linter_reports_a_text_outside_the_root_as_a_failure
      FileUtils.cp_r("#{fixture_path('repo_name_module')}/.", @root)
      File.delete(File.join(@root, 'lessons/01/01-text.md'))
      # The metadata linters read the text before the parse, so it needs a metadata block
      link('lessons/01/01-text.md', write('../outside/linked-target.md', markdown('Getting Started')))
      commit(remote: 'git@github.com:kodecocodes/m3-devtest.git')
      output = Linting::ContentModuleLinter.new(file: File.join(@root, 'module.yaml')).lint(options: MODULE_LINT_OPTIONS)

      assert_parse_failure(output, 'Unable to parse content module.', path: 'lessons/01/lesson.yaml', refused: 'text lessons/01/01-text.md')
    end

    def test_the_book_linter_reports_a_chapter_outside_the_root_as_a_failure
      link('chapters/02.md')
      book(chapter: 'chapters/02.md', **BOOK_METADATA)
      commit(remote: 'git@github.com:kodecocodes/test-book.git')
      output = Linting::BookLinter.new(file: File.join(@root, 'publish.yaml')).lint(options: BOOK_LINT_OPTIONS)

      assert_parse_failure(output, 'Unable to parse book.', path: 'publish.yaml', refused: 'chapter chapters/02.md')
    end
  end
end
