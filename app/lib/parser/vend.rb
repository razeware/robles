# frozen_string_literal: true

module Parser
  # Parses a vend.yaml file, and returns a hash of contributors & price_band
  class Vend
    include Util::PathExtraction

    def parse
      {
        contributors: contributors,
        price_band: vend_file[:price_band],
        edition: vend_file[:edition]
      }
    end

    def contributors
      return [] unless vend_file[:contributors].present?

      vend_file[:contributors].map do |contributor_attributes|
        Contributor.new(contributor_attributes)
      end
    end

    private

    def vend_file
      @vend_file ||= Psych.load_file(file).deep_symbolize_keys
    end
  end
end
