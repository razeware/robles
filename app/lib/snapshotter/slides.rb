# frozen_string_literal: true

require 'resolv'

module Snapshotter
  # Creates snapshots of all the slides in a video course
  class Slides
    attr_reader :app_host, :app_port, :snapshot_host, :snapshot_port, :out_dir

    def initialize(data:, app_host: 'app', app_port: 4567, snapshot_host: 'snapshot', snapshot_port: 3000, out_dir: '/data/src/slides') # rubocop:disable Metrics/ParameterLists
      @data = data
      @app_host = app_host
      @app_port = app_port
      @snapshot_host = snapshot_host
      @snapshot_port = snapshot_port
      @out_dir = out_dir
    end

    def generate
      raise 'Override this in a subclass please'
    end

    def browser
      @browser ||= Ferrum::Browser.new(url: "http://#{snapshot_host}:#{snapshot_port}", window_size: [1920, 1080], timeout: 15)
    end

    def app_base
      @app_base ||= begin
        ip = Resolv.getaddress(app_host)
        "http://#{ip}:#{app_port}"
      end
    end
  end
end
