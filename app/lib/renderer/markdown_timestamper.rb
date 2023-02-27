# frozen_string_literal: true

module Renderer
  # Methods that make it possible to render markdown from an object
  class MarkdownTimestamper
    include Util::Logging

    attr_reader :document, :vtt_path

    def initialize(document, vtt_path)
      @document = document
      @vtt_path = vtt_path
    end

    def apply! # rubocop:disable Metrics/MethodLength, Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
      return if vtt.blank?

      document.walk.each do |node|
        # We only care about paragraph nodes
        next unless node.type == :paragraph

        # Get the plain text for this paragraph and tidy it up
        paragraph = node.to_plaintext.gsub("\n", ' ').strip

        # Skip if this paragraph already contains a timestamp marker
        next if paragraph.match?(/\$\[t=[\d:.]+\]/)

        word_count = paragraph.split.length

        # Search the captions for a match for this paragraph
        match = (0..vtt.cues.length).map do |offset|
          vtt_wc = 0
          i = 0
          caption = +''
          # Join subtitles together until we've got something long enough for the paragraph
          while vtt_wc < word_count && offset + i < vtt.cues.length
            caption << " #{vtt.cues[offset + i].text}"
            vtt_wc = caption.split.length
            i += 1
          end

          # Match the word count
          caption = caption.split[0...paragraph.split.length].join(' ')

          # Calculate the similarity
          [offset, Levenshtein.distance(caption, paragraph), caption, paragraph]
        end
        match = match.min { |a, b| a[1] <=> b[1] }

        cue = vtt.cues[match[0]]
        text = CommonMarker::Node.new(:text)
        text.string_content = "$[t=#{cue.start}]"
        node.prepend_child(text)
      end
    end

    def vtt
      @vtt ||= WebVTT.read(vtt_path) if vtt_path.present?
    end
  end
end
