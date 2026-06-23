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

        # Blockquotes are callouts, not spoken-at-a-timestamp content. Skip every
        # paragraph (and nested list item) inside one, so we don't render a
        # timestamp in the gutter outside the quote or alongside its contents.
        next if inside_blockquote?(node)

        # Lists get a single timestamp for the whole list rather than one per
        # item, so only stamp the first paragraph of the first item.
        next if list_item_paragraph?(node) && !first_list_paragraph?(node)

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

    private

    # True if any ancestor of the node is a blockquote (handles paragraphs and
    # list items nested at any depth inside the quote).
    def inside_blockquote?(node)
      ancestor = node.parent
      while ancestor
        return true if ancestor.type == :blockquote

        ancestor = ancestor.parent
      end
      false
    end

    def list_item_paragraph?(node)
      node.parent&.type == :list_item
    end

    # The very first paragraph of the very first item of its list. Loose list
    # items can hold several paragraphs, so we check both the item and the
    # paragraph position to guarantee exactly one timestamp per list.
    def first_list_paragraph?(node)
      list_item = node.parent
      list = list_item.parent
      list_item == list.first_child && list_item.first_child == node
    end
  end
end
