# frozen_string_literal: true

module Snapshotter
  # Creates snapshots of all the slides in a content module
  class ContentModule < Slides
    def generate
      data.each do |lesson|
        lesson.segments.each do |segment|
          next unless segment.is_a?(Video)

          browser.goto("#{app_base}/slides/#{lesson.slug}/#{episode.slug}")
          browser.screenshot(path: "#{out_dir}/#{lesson-ref}-#{episode.slug}.png", selector: '#slide-to-snapshot')
        end
      end
    end
  end
end
