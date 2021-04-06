# frozen_string_literal: true

require 'active_support'
require 'active_support/core_ext/string/inflections'
require 'rack-livereload'

# A local preview server for robles
class RoblesBookServer < Sinatra::Application
  set :bind, '0.0.0.0'
  set :views, __dir__ + '/views'
  set :public_folder, __dir__ + '/public'
  set :static_cache_control, [max_age: 0]

  use Rack::LiveReload, host: '0.0.0.0'

  helpers do
    def chapter_path(chapter)
      "/chapters/#{chapter.slug}"
    end
  end

  before do
    cache_control max_age: 0
  end

  get '/' do
    erb :'books/index.html', locals: { book: book, title: "robles Preview: #{book.title}" }, layout: :'books/layout.html'
  end

  get '/chapters/:slug' do
    chapter = chapter_for_slug(params[:slug])
    raise Sinatra::NotFound unless chapter.present?

    render_chapter(chapter)
    erb :'books/chapter.html',
        locals: { chapter: chapter, book: book, title: "robles Preview: #{chapter.title}" },
        layout: :'books/layout.html'
  end

  get '/assets/*' do
    local_url = File.join('/data/src/', params[:splat])
    raise Sinatra::NotFound unless acceptable_image_extension(File.extname(local_url)) && File.exist?(local_url)

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
      book.markdown_render_loop do |content, file|
        render_string(content) unless file
      end
      book
    end
  end

  def render_string(content)
    Renderer::MarkdownStringRenderer.new(content: content).render
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
    [OpenStruct.new(url: local_url&.gsub(%r{/data/src}, '/assets'), variant: :original)]
  end

  def acceptable_image_extension(extension)
    %w[jpg jpeg png gif].include?(extension.sub('.', '').downcase)
  end
end
