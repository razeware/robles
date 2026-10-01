# frozen_string_literal: true

require_relative '../test_helper'

# The word counts the module preview shows for segments and whole lessons
class RoblesContentModuleServerTest < Minitest::Test
  include TestHelpers

  def setup
    # new! skips the middleware, giving the same instance the views call into
    @server = RoblesContentModuleServer.new!
  end

  def test_texts_are_counted
    assert_equal 107, @server.word_count(Text.new(markdown_file: prose))
  end

  def test_videos_count_their_script
    assert_equal 107, @server.word_count(Video.new(script_file: prose))
  end

  def test_videos_without_a_script_have_no_count
    assert_nil @server.word_count(Video.new)
  end

  def test_assessments_have_no_count
    assert_nil @server.word_count(Assessment::Quiz.new)
  end

  def test_a_lessons_count_adds_up_its_texts_and_videos
    lesson = Lesson.new(segments: [
                          Text.new(markdown_file: prose),
                          Video.new(script_file: prose),
                          Video.new,
                          Assessment::Quiz.new
                        ])

    assert_equal 214, @server.lesson_word_count(lesson)
  end

  private

  def prose
    fixture_path('markdown/prose.md')
  end
end
