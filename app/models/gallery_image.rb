# frozen_string_literal: true

# Subclass of image suitable for creating a gallery view
class GalleryImage < Image
  attr_accessor :directory

  def category
    dir = relative_path.dirname.to_s
    return nil if dir == '.'

    dir
  end

  def title
    filename.gsub('-', ' ')
  end

  def relative_path
    Pathname.new(local_url).relative_path_from(directory)
  end

  def filename
    Pathname.new(local_url).basename('.*').to_s
  end
end
