# frozen_string_literal: true

require 'resolv'

module Snapshotter
  # Creates snapshots of all the slides in a video course
  class Slides
    attr_reader :video_course, :app_host, :app_port, :snapshot_host, :snapshot_port, :out_dir

    def initialize(video_course:, app_host: 'app', app_port: 4567, snapshot_host: 'snapshot', snapshot_port: 3000, out_dir: '/data/src/slides') # rubocop:disable Metrics/ParameterLists
      @video_course = video_course
      @app_host = app_host
      @app_port = app_port
      @snapshot_host = snapshot_host
      @snapshot_port = snapshot_port
      @out_dir = out_dir
    end

    def generate
      browser = Ferrum::Browser.new(url: "http://#{snapshot_host}:#{snapshot_port}", window_size: [1920, 1080], timeout: 15)
      video_course.parts.flat_map(&:episodes).each do |episode|
        next unless episode.is_a?(Video)

        browser.goto("#{app_base}/slides/#{episode.slug}")
        browser.screenshot(path: "#{out_dir}/#{episode.slug}.png", selector: '#slide-to-snapshot')
      end
    end

    def app_base
      @app_base ||= begin
        ip = Resolv.getaddress(app_host)
        "http://#{ip}:#{app_port}"
      end
    end
  end
end
