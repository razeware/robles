# frozen_string_literal: true

module Linting
  # An object that represents the output for GitHub checks
  class Output
    include ActiveModel::Model
    include ActiveModel::Serializers::JSON

    attr_accessor :title, :summary, :text, :annotations, :validated

    # Used for serialisation
    def attributes
      { title: nil, summary: nil, text: nil, annotations: [] }.stringify_keys
    end
  end
end
