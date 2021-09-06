# frozen_string_literal: true

require 'rack-livereload'

# A local preview server for pablo
class RoblesPabloServer < Sinatra::Application
  set :bind, '0.0.0.0'
  set :views, "#{__dir__}/views"
  set :public_folder, "#{__dir__}/public"
  set :static_cache_control, [max_age: 0]

  use Rack::LiveReload, host: 'localhost', source: :vendored

  helpers do
    def image_url(image)
      image.local_url.gsub(%r{/data/src/razefaces}, '/assets')
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

  get '/assets/*' do
    local_url = File.join('/data/src/razefaces/', params[:splat])
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


  def image_list
    @image_list ||= begin
      extractor = ImageProvider::DirectoryExtractor.new('/data/src/razefaces')
      extractor.extract
      extractor.images
    end
  end

  def categories
    image_list.map(&:category).uniq.compact_blank
  end
end
