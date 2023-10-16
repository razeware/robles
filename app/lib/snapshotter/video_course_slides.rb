# frozen_string_literal: true

module Snapshotter
  # Creates snapshots of all the slides in a video course
  class VideoCourseSlides < Slides
    def generate
      data.each do |episode|
        next unless episode.is_a?(Video)

        browser.goto("#{app_base}/slides/#{episode.slug}")
        browser.screenshot(path: "#{out_dir}/#{episode.slug}.png", selector: '#slide-to-snapshot')
      end
    end
  end
end
