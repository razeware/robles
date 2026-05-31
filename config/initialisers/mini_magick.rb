# frozen_string_literal: true

# Bound how long any single ImageMagick command may run. Resizing large
# animated GIFs can otherwise take a very long time (or effectively hang),
# which would block module circulation in CI indefinitely. When the limit is
# exceeded MiniMagick raises, which is logged and surfaced by the image
# uploader rather than hanging the job.
MiniMagick.configure do |config|
  config.timeout = ENV.fetch('ROBLES_MINI_MAGICK_TIMEOUT', 120).to_i
end
