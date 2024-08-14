# frozen_string_literal: true

require 'rack-livereload'

# A local preview server for robles
class RoblesContentModuleServer < Sinatra::Application # rubocop:disable Metrics/ClassLength
  set :bind, '0.0.0.0'
  set :views, "#{__dir__}/views"
  set :public_folder, "#{__dir__}/public"
  set :static_cache_control, [max_age: 0]

  use Rack::LiveReload, host: 'localhost', source: :vendored

  helpers do
    def slide_path(lesson, segment)
      "/slides/#{lesson.slug}/#{segment.slug}"
    end

    def transcript_path(lesson, segment)
      "/transcripts/#{lesson.slug}/#{segment.slug}"
    end

    def assessment_path(lesson, segment)
      "/assessments/#{lesson.slug}/#{segment.slug}"
    end

    def text_path(lesson, segment)
      "/texts/#{lesson.slug}/#{segment.slug}"
    end

    def segment_path(lesson, segment)
      if segment.is_a?(Video)
        transcript_path(lesson, segment)
      elsif segment.is_a?(Assessment)
        assessment_path(lesson, segment)
      elsif segment.is_a?(Text)
        text_path(lesson, segment)
      end
    end

    def class_for_domain(course)
      if course.domains.count > 1
        'multi-domain'
      else
        course.domains.first
      end
    end

    # scss is no longer a built-in helper in sinatra
    # However, we can almost just proxy it to Tilt
    def scss(template, options = {}, locals = {})
      options.merge!(layout: false, exclude_outvar: true)
      # Set the content type to css
      render(:scss, template, options, locals).dup.tap do |css|
        css.extend(ContentTyped).content_type = :css
      end
    end
  end

  before do
    cache_control max_age: 0
  end

  get '/' do
    @content_module = content_module(with_transcript: false)
    erb :'content_modules/index.html', locals: { content_module: @content_module, title: "robles Preview: #{@content_module.title}" }, layout: :'content_modules/layout.html'
  end

  get '/slides/:lesson_slug/:slug' do
    @content_module = content_module(with_transcript: false)
    lesson = lesson_for_slug(params[:lesson_slug])
    segment = segment_for_slug(lesson, params[:slug])
    raise Sinatra::NotFound unless segment.present?

    erb :'content_modules/segment_slide.html',
        locals: { segment:, lesson:, content_module: @content_module, title: "robles Preview: #{segment.title}" },
        layout: :'content_modules/layout.html'
  end

  get '/transcripts/:lesson_slug/:slug' do
    @content_module = content_module(with_transcript: true)
    lesson = lesson_for_slug(params[:lesson_slug])
    segment = segment_for_slug(lesson, params[:slug])
    raise Sinatra::NotFound unless segment.present?

    erb :'content_modules/segment_transcript.html',
        locals: { segment:, lesson:, content_module: @content_module, title: "robles Preview: #{segment.title}" },
        layout: :'content_modules/layout.html'
  end

  get '/assessments/:lesson_slug/:slug' do
    @content_module = content_module(with_transcript: false)
    lesson = lesson_for_slug(params[:lesson_slug])
    segment = segment_for_slug(lesson, params[:slug])
    raise Sinatra::NotFound unless segment.present?

    erb :'content_modules/assessment.html',
        locals: { segment:, lesson:, content_module: @content_module, title: "robles Preview: #{segment.title}" },
        layout: :'content_modules/layout.html'
  end

  get '/texts/:lesson_slug/:slug' do
    @content_module = content_module(with_transcript: false)
    lesson = lesson_for_slug(params[:lesson_slug])
    segment = segment_for_slug(lesson, params[:slug])
    raise Sinatra::NotFound unless segment.present?

    render_text(segment)

    erb :'content_modules/text.html',
        locals: {
          segment:,
          content_module: @content_module,
          title: "robles Preview: #{segment.title}",
          word_counter: word_counter_for_segment(segment)
        },
        layout: :'content_modules/layout.html'
  end

  get '/assets/*' do
    local_url = File.join('/data/src/', params[:splat])
    raise Sinatra::NotFound unless acceptable_image_extension(File.extname(local_url)) && File.exist?(local_url)

    send_file(local_url)
  end

  get '/styles.css' do
    scss :'styles/application', style: :expanded
  end

  def content_module(with_transcript: true)
    parser = Parser::Circulate.new(file: module_file)
    content_module = parser.parse
    renderer = Renderer::ContentModule.new(content_module, image_provider: nil)
    renderer.disable_transcripts = !with_transcript
    renderer.render
    content_module.image_attachment_loop { |local_url| servable_image_url(local_url) }
    content_module
  end

  def render_text(text)
    image_provider = LocalImageProvider.new(container: text)
    image_provider.process
    renderer = Renderer::Segment.create(text, image_provider:)
    renderer.render
  end

  def render_string(content)
    Renderer::MarkdownStringRenderer.new(content:).render
  end

  def word_counter_for_segment(segment)
    markdown = File.read(segment.markdown_file)
    Linting::Markdown::WordCounter.new(markdown)
  end

  def lesson_for_slug(slug)
    @content_module.lessons.find { |lesson| lesson.slug == slug }
  end

  def segment_for_slug(lesson, slug)
    lesson.segments.find { |segment| segment.slug == slug }
  end

  def module_file
    '/data/src/module.yaml'
  end

  def servable_image_url(local_url)
    [OpenStruct.new(url: local_url&.gsub(%r{/data/src}, '/assets'), variant: :original)] # rubocop:disable Style/OpenStructUse
  end

  def acceptable_image_extension(extension)
    %w[jpg jpeg png gif].include?(extension.sub('.', '').downcase)
  end
end
