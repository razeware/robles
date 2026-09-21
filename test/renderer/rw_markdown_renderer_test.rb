# frozen_string_literal: true

require 'tmpdir'
require_relative '../test_helper'
require_relative '../support/fake_image_provider'

module Renderer
  # Characterisation tests for the custom image and timestamp rendering. This is
  # the markup the published site's CSS and JavaScript are written against, so
  # the assertions are deliberately on the exact HTML.
  class RWMarkdownRendererTest < Minitest::Test
    include TestHelpers

    def render_fixture(name, image_provider:)
      MarkdownFileRenderer.new(path: fixture_path("markdown/#{name}"), image_provider:).render
    end

    def render_string(markdown, image_provider:)
      Dir.mktmpdir do |dir|
        path = File.join(dir, 'body.md')
        File.write(path, markdown)
        MarkdownFileRenderer.new(path:, image_provider:).render
      end
    end

    def test_renders_the_whole_image_corpus
      html = render_fixture('images.md', image_provider: FakeImageProvider.new)

      assert_rendered_html('markdown/images.file_renderer.html', html)
    end

    def test_width_not_required_renders_unsized_images_as_figures
      html = render_fixture('images.md', image_provider: FakeImageProvider.new(width_required: false))

      assert_rendered_html('markdown/images.width_optional.file_renderer.html', html)
    end

    def test_without_an_image_provider_images_fall_back_to_plain_img_tags
      assert_equal %(<p><img src="assets/screenshot.png" alt="width=50%" title="A title" /></p>\n),
                   render_string(%(![width=50%](assets/screenshot.png "A title")\n), image_provider: nil)
    end

    # Note the surrounding <p>: the image is an inline node, so the block-level
    # replacement markup is emitted inside the paragraph that held it. Invalid
    # HTML, but it is what the published site has always been built with.
    def test_a_missing_width_produces_the_red_error_blockquote
      html = render_string("![no width here](assets/screenshot.png)\n", image_provider: FakeImageProvider.new)

      expected = '<p><blockquote>  <h3 style="color: red; margin-top: 0;">Error: This image is missing a width attribute</h3>  <p style="color: red;">Please provide one in the form of <code>![width=50%](assets/screenshot.png)</code></p>  <p style="color: red;">The image has been hidden until this issue is resolved.</p></blockquote></p>'

      assert_equal "#{expected}\n", html
    end

    def test_a_title_is_html_escaped_in_every_slot_it_appears_in
      html = render_string(%(![width=50%](assets/screenshot.png "Tom & \\"Jerry\\"")\n), image_provider: FakeImageProvider.new)

      assert_includes html, '<figure title="Tom &amp; &quot;Jerry&quot;" class="l-image-50">'
      assert_includes html, 'alt="Tom &amp; &quot;Jerry&quot;"'
      assert_includes html, '<figcaption>Tom &amp; &quot;Jerry&quot;</figcaption>'
    end

    def test_a_timestamp_marker_becomes_a_span_and_leaves_the_rest_of_the_text
      html = render_string("$[t=00:12.3]Now we build the view.\n", image_provider: nil)

      assert_equal %(<p><span data-video-timestamp="00:12.3"></span>Now we build the view.</p>\n), html
    end

    # A paragraph is a single text node, so only the first marker becomes a span;
    # the rest are stripped from the text. Documenting the behaviour as it is.
    def test_only_the_first_of_several_timestamps_in_a_paragraph_becomes_a_span
      html = render_string("$[t=00:01.0]One and $[t=00:02.0]two.\n", image_provider: nil)

      assert_equal %(<p><span data-video-timestamp="00:01.0"></span>One and two.</p>\n), html
    end
  end
end
