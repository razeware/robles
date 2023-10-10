# frozen_string_literal: true

module Snapshotter
  # Creates snapshots of all the slides in a content module
  class ContentModuleSlides < Slides
    def generate
      data.each do |lesson|
        lesson.segments.each do |segment|
          next unless segment.is_a?(Video)

          browser.goto("#{app_base}/slides/#{lesson.slug}/#{segment.slug}")
          browser.screenshot(path: "#{out_dir}/#{lesson-ref}-#{segment.slug}.png", selector: '#slide-to-snapshot')
        end
      end
    end
  end
end
