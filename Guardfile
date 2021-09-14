# frozen_string_literal: true

# This guard file is used for development of robles
# We generate one in code for using robles as a local preview
guard 'livereload' do
  extensions = {
    css: :css,
    scss: :css,
    sass: :css,
    js: :js,
    coffee: :js,
    html: :html,
    png: :png,
    gif: :gif,
    jpg: :jpg,
    jpeg: :jpeg
  }

  # file types LiveReload may optimize refresh for
  compiled_exts = extensions.values.uniq
  watch(%r{app/server/public/.+\.(#{compiled_exts * '|'})})

  # file needing a full reload of the page anyway
  watch(%r{app/server/views/.+\.erb$})
  watch(%r{app/server/views/.+\.scss$})
end
