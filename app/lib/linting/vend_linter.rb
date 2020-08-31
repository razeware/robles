# frozen_string_literal: true

module Linting
  # Lints vend.yaml
  class VendLinter # rubocop:disable Metrics/ClassLength
    VALID_PRICE_BANDS = %w(free 2020_full_book 2020_short_book 2020_deprecated_book).freeze
    attr_reader :file, :vend_file

    def initialize(file:)
      @file = file
      @annotations = []
    end

    def lint
      load_file
      return @annotations unless @annotations.empty?

      check_price_band
      check_total_percentage
      return @annotations unless @annotations.empty?

      check_for_razeware_user
      @annotations
    end

    def check_price_band # rubocop:disable Metrics/MethodLength
      if vend_file[:price_band].blank?
        @annotations.push(
          Annotation.new(
            absolute_path: file,
            annotation_level: 'warning',
            start_line: 0,
            end_line: 0,
            title: 'Missing price_band attribute.',
            message: 'The price_band attribute allows this book to be sold individually and should be included for all books.'
          )
        )
      elsif !VALID_PRICE_BANDS.include?(vend_file[:price_band])
        @annotations.push(
          Annotation.new(
            absolute_path: file,
            annotation_level: 'failure',
            start_line: 0,
            end_line: 0,
            title: 'Invalid price_band attribute.',
            message: "price_band must be in (#{VALID_PRICE_BANDS.join(', ')})"
          )
        )
      end
    end

    def check_total_percentage # rubocop:disable Metrics/MethodLength
      if vend_file[:contributors].blank?
        @annotations.push(
          Annotation.new(
            absolute_path: file,
            annotation_level: 'warning',
            start_line: 0,
            end_line: 0,
            title: 'Missing contributors attribute.',
            message: 'The contributors attribute should be included for all books.'
          )
        )
        return
      end

      total_contributor_percentage = vend_file[:contributors].sum(&:percentage)
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
      return unless vend_file[:contributors].any? { |contributor| contributor.username == 'razeware' }

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

    def load_file # rubocop:disable Metrics/MethodLength
      @vend_file ||= begin
        parser = Parser::Vend.new(file: file)
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
