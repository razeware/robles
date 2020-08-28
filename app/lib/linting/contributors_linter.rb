# frozen_string_literal: true

module Linting
  # Lints contributors.yaml
  class ContributorsLinter
    attr_reader :file, :contributors

    def initialize(file:)
      @file = file
      @annotations = []
    end

    def lint
      load_contributors
      return @annotations unless @annotations.empty?

      check_total_percentage
      check_for_razeware_user
      @annotations
    end

    def check_total_percentage # rubocop:disable Metrics/MethodLength
      p contributors
      total_contributor_percentage = contributors.sum(&:percentage)
      return if total_contributor_percentage == 100

      @annotations.push(
        Annotation.new(
          absolute_path: file,
          annotation_level: 'failure',
          start_line: 0,
          end_line: 0,
          message: "The sum of all contributor percentages should be 100. It is currently #{total_contributor_percentage}.",
          title: 'Incorrect contribution sum.'
        )
      )
    end

    def check_for_razeware_user # rubocop:disable Metrics/MethodLength
      return unless contributors.any? { |contributor| contributor.username == 'razeware' }

      @annotations.push(
        Annotation.new(
          locate_razeware_username.merge(
            absolute_path: file,
            annotation_level: 'warning',
            message: "The publisher's contribution should be attributed to the _razeware user, not the razeware user.",
            title: 'Probable incorrect user.'
          )
        )
      )
    end

    private

    def load_contributors # rubocop:disable Metrics/MethodLength
      @contributors ||= begin
        parser = Parser::Contributors.new(file: file)
        parser.parse
      end
    rescue Parser::Error => e
      line_number = (e.message.match(/at line (\d+)/)&.captures&.first&.to_i || 0) + 1
      @annotations.push(
        Annotation.new(
          absolute_path: e.file,
          annotation_level: 'failure',
          start_line: line_number,
          end_line: line_number,
          message: e.message,
          title: 'Unable to parse contributors.'
        )
      )
    end

    def locate_razeware_username
      IO.foreach(file).with_index do |line, line_number|
        next unless line.include?('username: razeware')

        start_column = line.index('razeware')
        return {
          start_line: line_number + 1,
          end_line: line_number + 1,
          start_column: start_column + 1,
          end_column: start_column + 'razeware'.length + 1
        }
      end
    end
  end
end
