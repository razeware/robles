# A sample Guardfile
# More info at https://github.com/guard/guard#readme

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
    jpeg: :jpeg,
  }

  # file types LiveReload may optimize refresh for
  compiled_exts = extensions.values.uniq
  watch(%r{app/server/public/.+\.(#{compiled_exts * '|'})})

  # file needing a full reload of the page anyway
  watch(%r{app/server/views/.+\.erb$})
  watch('app/server/views/styles/**/*.scss')
  watch(%r{^/data/src/publish\.yaml$})
  watch(%r{^/data/src/(.+)/(.+)\.(md|markdown)$})
end
