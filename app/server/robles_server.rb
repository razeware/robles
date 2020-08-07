# frozen_string_literal: true
require 'rack-livereload'

# A local preview server for robles
class RoblesServer < Sinatra::Application
  set :bind, '0.0.0.0'
  set :views, __dir__ + '/views'

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

  def book
    @book ||= begin
      parser = Parser::Publish.new(file: publish_file)
      book = parser.parse
      book
    end
  end

  def chapter_for_slug(slug)
    book.sections.flat_map(&:chapters).find { |chapter| chapter.slug == slug }
  end

  def render_chapter(chapter)
    renderer = Renderer::Chapter.new(chapter)
    renderer.render
  end

  def publish_file
    '/data/src/publish.yaml'
  end
end
