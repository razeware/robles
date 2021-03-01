# frozen_string_literal: true

module ImageProvider
  # Extract all images from a video course
  class VideoCourseExtractor
    attr_reader :video_course, :images

    def initialize(video_course)
      @video_course = video_course
      @images = []
    end

    def extract
      @images = image_paths.map do |path|
        Image.with_representations({ local_url: path[:absolute_path], uploaded_image_root_path: uploaded_image_root_path }, variants: path[:variants])
      end
    end

    def uploaded_image_root_path
      "videos/#{video_course.shortcode}/images"
    end

    def image_paths
      video_course.image_attachment_paths
    end
  end
end
