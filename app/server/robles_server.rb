# frozen_string_literal: true
require 'rack-livereload'

# A local preview server for robles
class RoblesServer < Sinatra::Application
  set :bind, '0.0.0.0'
  set :views, __dir__ + '/views'

  use Rack::LiveReload, host: '0.0.0.0'

  get '/' do
    erb :'index.html', locals: { book: book, title: "robles Preview: #{book.title}" }, layout: :'layout.html'
  end

  def book
    parser = Parser::Publish.new(file: publish_file)
    book = parser.parse
    book
  end

  def publish_file
    '/data/src/publish.yaml'
  end
end
