# frozen_string_literal: true

module Linting
  # An object that represents the annotation we'd upload to GitHub on linting failure
  class Annotation
    include ActiveModel::Model
    include ActiveModel::Serializers::JSON

    class_attribute :root_directory, instance_writer: false

    attr_accessor :absolute_path, :start_line, :end_line, :start_column, :end_column,
                  :annotation_level, :message, :title

    def path
      raise 'Missing root_directory' unless root_directory?

      Pathname.new(absolute_path).relative_path_from(root_directory).to_s
    end

    def cli_title
      "#{cli_glyph} #{title}"
    end

    def cli_glyph
      case annotation_level.to_sym
      when :notice
        '{{i}}'
      when :warning
        '{{*}}'
      else
        '{{x}}'
      end
    end

    def cli_colour
      case annotation_level.to_sym
      when :notice
        :cyan
      when :warning
        :yellow
      else
        :red
      end
    end

    # Used for serialisation
    def attributes
      { path: nil, start_line: nil, end_line: nil, start_column: nil, end_column: nil,
        annotation_level: nil, message: nil, title: nil }.stringify_keys
    end
  end
end
