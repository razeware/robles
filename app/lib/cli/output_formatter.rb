# frozen_string_literal: true

module Cli
  # Render the output object to the screen
  class OutputFormatter
    attr_reader :output

    def self.render(output)
      new(output:).render
    end

    def initialize(output:)
      @output = output
    end

    def render
      case [output.validated, output.annotations.blank?]
      when [true, true]
        success
      when [true, false]
        warnings
      else
        failure
      end
    end

    def success
      CLI::UI::Frame.open('{{v}} {{bold:robles}} Linting Successful!', color: :green) do
        puts CLI::UI.fmt "{{success:#{output.title}}}"
        puts output.summary
        CLI::UI::Frame.divider('Details')
        puts output.text
      end
    end

    def warnings
      CLI::UI::Frame.open('{{x}} {{bold:robles}} Linting Warnings', color: :yellow) do
        puts CLI::UI.fmt("{{warning:#{output.title}}}")
        puts output.summary
        CLI::UI::Frame.divider('Details')
        puts output.text
        CLI::UI::Frame.divider('{{x}} Individual Annotations')
        output.annotations.each { |annotation| render_annotation(annotation) }
      end
    end

    def failure
      CLI::UI::Frame.open('{{x}} {{bold:robles}} Linting Failure {{yellow:=(}}', color: :red) do
        puts CLI::UI.fmt("{{error:#{output.title}}}")
        puts output.summary
        CLI::UI::Frame.divider('Details')
        puts output.text
        CLI::UI::Frame.divider('{{x}} Individual Annotations')
        output.annotations.each { |annotation| render_annotation(annotation) }
      end
    end

    def render_annotation(annotation)
      CLI::UI::Frame.open(annotation.cli_title, color: annotation.cli_colour) do
        puts CLI::UI.fmt("{{bold:#{annotation.path}:#{annotation.start_line}}}")
        puts annotation.message
      end
    end
  end
end
