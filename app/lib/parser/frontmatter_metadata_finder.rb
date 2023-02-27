# frozen_string_literal: true

module Parser
  # Locates the metadata frontmatter in a MD file
  module FrontmatterMetadataFinder
    START_DELIMITER = '```metadata'
    END_DELIMITER   = '```'

    def find_metadata(lines_enumerator)
      metadata_locator(lines_enumerator)
    end

    def without_metadata(lines_enumerator)
      metadata_locator(lines_enumerator, keep: false)
    end

    def metadata_locator(lines_enumerator, keep: true) # rubocop:disable Metrics/MethodLength, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
      [].tap do |output|
        metadata_started = false
        metadata_ended = false
        lines_enumerator.each do |line|
          # Remove trailing whitespace
          line.chomp!

          # NB: This uses pattern matching, which is apparently experimental. Might need to
          #     fix this in later versions of Ruby, since it is apparently open to changes.
          case [metadata_started, metadata_ended, line, keep]
          in [false, _, START_DELIMITER, _]
            # Hit the metadata start line
            metadata_started = true
          in [false, _, _, false]
            # Not started metadata yet, and we're collecting the non-meta section
            output << line
          in [true, false, END_DELIMITER, false]
            # Hit the metadata end line, and need to keep going
            metadata_ended = true
          in [true, false, END_DELIMITER, true]
            # We're only interest in the meta section, so we're done
            break
          in [true, false, _, true] # rubocop:disable Lint/DuplicateBranch
            # We're in the metadata section, and we're collecting the metadata section
            output << line
          in [true, true, _, false] # rubocop:disable Lint/DuplicateBranch
            # We've finished the meta section--collect the remaining lines
            output << line
          in [_, _, _, _]
            # Catchall no-op
          end
        end
      end.join("\n")
    end
  end
end
