# frozen_string_literal: true

# Remove Chapter/Section at the beginning
module TitleCleanser
  def cleanse_title!
    title.gsub!(/^(Chapter|Section) \d+: /, '')
  end
end
