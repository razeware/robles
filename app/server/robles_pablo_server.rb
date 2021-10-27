# frozen_string_literal: true

require 'rack-livereload'

# A local preview server for pablo
class RoblesPabloServer < Sinatra::Application
  set :bind, '0.0.0.0'
  set :views, "#{__dir__}/views"
  set :public_folder, "#{__dir__}/public"
  set :static_cache_control, [max_age: 0]
  set :image_extractor, nil
  set :local, true

  use Rack::LiveReload, host: 'localhost', source: :vendored unless ENV['DISABLE_LIVERELOAD']

  register Sinatra::Pablo

  helpers do
    def image_url(image, variant: :small)
      image.representations.find { _1.variant == variant }&.remote_url
    end
  end

  before do
    cache_control max_age: 0
  end

  get '/' do
    erb :'pablo/index.html',
        locals: { images: image_list, categories: categories },
        layout: :'pablo/layout.html'
  end

  get '/home' do
    erb :'pablo/index.html',
        locals: { images: image_list, categories: categories },
        layout: :'pablo/layout.html'
  end

  get '/license' do
    erb :'pablo/license.html',
        layout: :'pablo/layout.html'
  end

  get '/instructions' do
    erb :'pablo/instructions.html',
        layout: :'pablo/layout.html'
  end

  get '/assets/*' do
    local_url = File.join('/data/src', params[:splat])
    raise Sinatra::NotFound unless File.exist?(local_url)

    send_file(local_url)
  end

  get '/styles.css' do
    scss :'pablo/styles/pablo', style: :expanded
  end

  get '/:category' do
    category = params[:category]
    raise Sinatra::NotFound unless categories.include?(category)

    filtered_image_list = image_list.filter { |image| image.category == category }

    erb :'pablo/index.html',
        locals: { images: filtered_image_list, categories: categories, selected_category: category },
        layout: :'pablo/layout.html'
  end

  private

  def image_list
    extractor.images
  end

  def categories
    extractor.categories
  end

  def extractor
    @extractor ||= settings.image_extractor.extract
  end
end
