# Based on https://github.com/hooktstudios/sinatra-export MIT Licensed

require 'sinatra/base'
require 'rack/test'

module Sinatra
  module Pablo
    def self.registered(app)
      app.set :export_extensions, %w(css js xml json html csv)
      app.extend ClassMethods
      app.set :builder, nil
    end

    module ClassMethods
      def save!(paths:, destination: nil, options: {})
        set options
        @builder ||= 
          if self.builder
            self.builder
          else
            Builder.new(self, paths: paths, destination: destination)
          end
        @builder.build!
      end
    end

    class Builder
      include Rack::Test::Methods

      attr_reader :app, :paths, :destination

      def initialize(app, paths: [], destination: nil)
        @app = app
        @paths  = paths
        @destination = destination
      end

      def build!
        raise 'Cannot save site without destination' if destination.blank?

        dir = Pathname(destination)

        # Empty out the destination
        ::FileUtils.rm_rf(dir)
        ::FileUtils.mkdir_p(destination)

        paths.each do |path|
          response = get(path)
          save_path(path: path, dir: dir, response: response)
        end
      end

      def save_path(path:, dir:, response:)
        body = response.body
        mtime = response.headers.key?("Last-Modified") ?
          Time.httpdate(response.headers["Last-Modified"]) : Time.now

        pattern = %r{
          [^/\.]+
          \.
          (
            #{app.settings.export_extensions.join("|")}
          )
        $}x
        file_path = Pathname(File.join(dir, path))
        file_path = file_path.join('index.html') unless path.match(pattern)
        ::FileUtils.mkdir_p(file_path.dirname)
        ::File.open(file_path, 'w+') do |f|
          f.write(body)
        end
        ::FileUtils.touch(file_path, mtime: mtime)
        file_path
      end
    end
  end

  register Pablo
end

