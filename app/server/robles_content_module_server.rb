# frozen_string_literal: true

require 'rack-livereload'

# A local preview server for robles
class RoblesContentModuleServer < Sinatra::Application
  set :bind, '0.0.0.0'
  set :views, "#{__dir__}/views"
  set :public_folder, "#{__dir__}/public"
  set :static_cache_control, [max_age: 0]

  use Rack::LiveReload, host: 'localhost', source: :vendored

  helpers do
    def slide_path(segment)
      "/slides/#{segment.slug}"
    end

    def transcript_path(segment)
      "/transcripts/#{segment.slug}"
    end

    def assessment_path(segment)
      "/assessments/#{segment.slug}"
    end

    def text_path(segment)
      "/texts/#{segment.slug}"
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

  get '/slides/:slug' do
    @content_module = content_module(with_transcript: false)
    segment = segment_for_slug(params[:slug])
    raise Sinatra::NotFound unless segment.present?

    lesson = @content_module.lessons.find { |p| p.segments.include?(segment) }

    erb :'content_modules/segment_slide.html',
        locals: { segment:, lesson:, content_module: @content_module, title: "robles Preview: #{segment.title}" },
        layout: :'content_modules/layout.html'
  end

  get '/transcripts/:slug' do
    @content_module = content_module(with_transcript: true)
    segment = segment_for_slug(params[:slug])
    raise Sinatra::NotFound unless segment.present?

    lesson = @content_module.lessons.find { |p| p.segments.include?(segment) }

    erb :'content_modules/segment_transcript.html',
        locals: { segment:, lesson:, content_module: @content_module, title: "robles Preview: #{segment.title}" },
        layout: :'content_modules/layout.html'
  end

  get '/assessments/:slug' do
    @content_module = content_module(with_transcript: false)
    segment = segment_for_slug(params[:slug])
    raise Sinatra::NotFound unless segment.present?

    lesson = @content_module.lessons.find { |p| p.segments.include?(segment) }

    erb :'content_modules/assessment.html',
        locals: { segment:, lesson:, content_module: @content_module, title: "robles Preview: #{segment.title}" },
        layout: :'content_modules/layout.html'
  end

  get '/texts/:slug' do
    @content_module = content_module(with_transcript: false)
    segment = segment_for_slug(params[:slug])
    raise Sinatra::NotFound unless segment.present?

    lesson = @content_module.lessons.find { |p| p.segments.include?(segment) }

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

  def render_string(content)
    Renderer::MarkdownStringRenderer.new(content:).render
  end

  def word_counter_for_segment(segment)
    markdown = File.read(segment.markdown_file)
    Linting::Markdown::WordCounter.new(markdown)
  end

  def segment_for_slug(slug)
    @content_module.lessons.flat_map(&:segments).find { |segment| segment.slug == slug }
  end

  def module_file
    '../m3-devtest/module.yaml'
  end

  def servable_image_url(local_url)
    [OpenStruct.new(url: local_url&.gsub(%r{/data/src}, '/assets'), variant: :original)] # rubocop:disable Style/OpenStructUse
  end

  def acceptable_image_extension(extension)
    %w[jpg jpeg png gif].include?(extension.sub('.', '').downcase)
  end
end
