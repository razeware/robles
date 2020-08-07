# frozen_string_literal: true

# A local preview server for robles
class RoblesServer < Sinatra::Application
  get '/' do
    'Hello world!'
  end
end
