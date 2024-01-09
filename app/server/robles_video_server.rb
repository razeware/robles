# frozen_string_literal: true

require 'rack-livereload'

# A local preview server for robles
class RoblesVideoServer < Sinatra::Application
  set :bind, '0.0.0.0'
  set :views, "#{__dir__}/views"
  set :public_folder, "#{__dir__}/public"
  set :static_cache_control, [max_age: 0]

  use Rack::LiveReload, host: 'localhost', source: :vendored

  helpers do
    def slide_path(episode)
      "/slides/#{episode.slug}"
    end

    def transcript_path(episode)
      "/transcripts/#{episode.slug}"
    end

    def assessment_path(episode)
      "/assessments/#{episode.slug}"
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
    @video_course = video_course(with_transcript: false)
    erb :'videos/index.html', locals: { video_course: @video_course, title: "robles Preview: #{@video_course.title}" }, layout: :'videos/layout.html'
  end

  get '/slides/:slug' do
    @video_course = video_course(with_transcript: false)
    episode = episode_for_slug(params[:slug])
    raise Sinatra::NotFound unless episode.present?

    part = @video_course.parts.find { |p| p.episodes.include?(episode) }

    erb :'videos/episode_slide.html',
        locals: { episode:, part:, video_course: @video_course, title: "robles Preview: #{episode.title}" },
        layout: :'videos/layout.html'
  end

  get '/transcripts/:slug' do
    @video_course = video_course(with_transcript: true)
    episode = episode_for_slug(params[:slug])
    raise Sinatra::NotFound unless episode.present?

    part = @video_course.parts.find { |p| p.episodes.include?(episode) }

    erb :'videos/episode_transcript.html',
        locals: { episode:, part:, video_course: @video_course, title: "robles Preview: #{episode.title}" },
        layout: :'videos/layout.html'
  end

  get '/assessments/:slug' do
    @video_course = video_course(with_transcript: false)
    episode = episode_for_slug(params[:slug])
    raise Sinatra::NotFound unless episode.present?

    part = @video_course.parts.find { |p| p.episodes.include?(episode) }

    erb :'videos/assessment.html',
        locals: { episode:, part:, video_course: @video_course, title: "robles Preview: #{episode.title}" },
        layout: :'videos/layout.html'
  end

  get '/assets/*' do
    local_url = File.join('/data/src/', params[:splat])
    raise Sinatra::NotFound unless acceptable_image_extension(File.extname(local_url)) && File.exist?(local_url)

    send_file(local_url)
  end

  get '/styles.css' do
    scss :'styles/application', style: :expanded
  end

  def video_course(with_transcript: true)
    parser = Parser::Release.new(file: release_file)
    video_course = parser.parse
    renderer = Renderer::VideoCourse.new(video_course, image_provider: nil)
    renderer.disable_transcripts = !with_transcript
    renderer.render
    video_course.image_attachment_loop { |local_url| servable_image_url(local_url) }
    video_course
  end

  def render_string(content)
    Renderer::MarkdownStringRenderer.new(content:).render
  end

  def episode_for_slug(slug)
    @video_course.parts.flat_map(&:episodes).find { |episode| episode.slug == slug }
  end

  def release_file
    '/data/src/release.yaml'
  end

  def servable_image_url(local_url)
    [OpenStruct.new(url: local_url&.gsub(%r{/data/src}, '/assets'), variant: :original)] # rubocop:disable Style/OpenStructUse
  end

  def acceptable_image_extension(extension)
    %w[jpg jpeg png gif].include?(extension.sub('.', '').downcase)
  end
end
