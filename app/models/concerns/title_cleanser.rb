# frozen_string_literal: true

module Concerns
  # Remove Chapter/Section at the beginning
  module TitleCleanser
    def cleanse_title!
      title.gsub!(/^(Chapter|Section) \d+: /, '')
    end
  end
end
