# frozen_string_literal: true
require 'rack-livereload'

# A local preview server for robles
class RoblesServer < Sinatra::Application
  set :bind, '0.0.0.0'
  set :views, __dir__ + '/views'
  set :public_folder, __dir__ + '/public'

  use Rack::LiveReload, host: '0.0.0.0'

  helpers do
    def chapter_path(chapter)
      "/chapters/#{chapter.slug}"
    end
  end

  get '/' do
    erb :'index.html', locals: { book: book, title: "robles Preview: #{book.title}" }, layout: :'layout.html'
  end

  get '/chapters/:slug' do
    chapter = chapter_for_slug(params[:slug])
    raise Sinatra::NotFound unless chapter.present?

    render_chapter(chapter)
    erb :'chapter.html',
        locals: { chapter: chapter, book: book, title: "robles Preview: #{chapter.title}" },
        layout: :'layout.html'
  end

  get '/assets/*.*' do
    local_url = File.join('/data/src/', params[:splat].join('.'))
    raise Sinatra::NotFound unless acceptable_image_extension(params[:splat].second) && File.exist?(local_url)

    send_file(local_url)
  end

  get '/styles.css' do
    scss :'styles/application', style: :expanded
  end

  def book
    @book ||= begin
      parser = Parser::Publish.new(file: publish_file)
      book = parser.parse
      book.image_attachment_loop { |local_url| servable_image_url(local_url) }
      book
    end
  end

  def chapter_for_slug(slug)
    book.sections.flat_map(&:chapters).find { |chapter| chapter.slug == slug }
  end

  def render_chapter(chapter)
    image_provider = LocalImageProvider.new(chapter: chapter)
    image_provider.process
    renderer = Renderer::Chapter.new(chapter, image_provider: image_provider)
    renderer.render
  end

  def publish_file
    '/data/src/publish.yaml'
  end

  def servable_image_url(local_url)
    local_url&.gsub(%r{/data/src}, '/assets')
  end

  def acceptable_image_extension(extension)
    %w[jpg png gif].include?(extension.downcase)
  end
end
