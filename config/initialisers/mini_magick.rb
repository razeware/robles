# frozen_string_literal: true

# Keep ImageMagick within a CI runner's resources when resizing images.
#
# Animated GIFs (e.g. screen recordings) hold every frame in memory while
# resizing. On the Alpine image ImageMagick self-caps at ~1GB and then spills to
# its slow disk-backed pixel cache, so a large GIF resize crawls and the
# circulate job appears to hang. We:
#
#   * raise the in-RAM limits so typical animated GIFs resize in memory (fast),
#   * bound the disk cache so a pathological image fails fast instead of
#     thrashing forever (MiniMagick raises, and the image uploader logs it),
#   * pin ImageMagick to a single thread, since robles already parallelises
#     across images (see ImageProvider::Provider#upload_concurrency), and
#   * cap CPU time per command as a backstop.
#
# Every limit is tunable via the environment so it can be sized to the runner.
# Note: peak RAM is roughly MAGICK_MEMORY_LIMIT x the image-upload concurrency,
# so keep that product comfortably below the runner's memory.
MiniMagick.configure do |config|
  config.timeout = ENV.fetch('ROBLES_MINI_MAGICK_TIMEOUT', 300).to_i
  config.cli_env = {
    'MAGICK_THREAD_LIMIT' => ENV.fetch('MAGICK_THREAD_LIMIT', '1'),
    'MAGICK_MEMORY_LIMIT' => ENV.fetch('MAGICK_MEMORY_LIMIT', '2GiB'),
    'MAGICK_MAP_LIMIT' => ENV.fetch('MAGICK_MAP_LIMIT', '2GiB'),
    'MAGICK_DISK_LIMIT' => ENV.fetch('MAGICK_DISK_LIMIT', '4GiB')
  }
end
