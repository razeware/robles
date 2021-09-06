# frozen_string_literal: true

# Subclass of image suitable for creating a gallery view
class GalleryImage < Image
  def category
    filename.split('_').first if filename.include?('_')
  end

  def title
    filename.delete_prefix(category || '').titleize
  end

  def filename
    Pathname.new(local_url).basename('.*').to_s.downcase
  end
end
