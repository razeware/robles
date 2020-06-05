# frozen_string_literal: true

module Util
  # Adds methods that allow slack notifications
  module SlackNotifiable # rubocop:disable Metrics/ModuleLength
    extend ActiveSupport::Concern

    SUCCESS_IMAGE_URL = 'https://wolverine.raywenderlich.com/v3-resources/razebot/images/object_textkit-book.png'
    FAILURE_IMAGE_URL = 'https://wolverine.raywenderlich.com/v3-resources/razebot/images/object_errors.png'
    ROBLES_CONTEXT_IMAGE_URL = 'https://wolverine.raywenderlich.com/v3-resources/razebot/images/object_box-of-books.png'

    def notify_success(book:)
      return unless notifiable?

      notifier.post(blocks: success_blocks(book: book))
    end

    def notify_failure(book:, details: nil)
      return unless notifiable?

      notifier.post(blocks: failure_blocks(book: book, details: details || 'N/A'))
    end

    def notifiable?
      SLACK_WEBHOOK_URL.present?
    end

    def notifier
      @notifier ||= Slack::Notifier.new(SLACK_WEBHOOK_URL, channel: SLACK_CHANNEL, username: SLACK_USERNAME)
    end

    def success_blocks(book:)
      [
        intro_section(book: book,
                      message: ':white_check_mark: Book publication successful!',
                      image_url: SUCCESS_IMAGE_URL,
                      alt_text: 'Publication successful'),
        {
          type: 'divider'
        },
        context
      ]
    end

    def failure_blocks(book:, details:) # rubocop:disable Metrics/MethodLength
      [
        intro_section(book: book,
                      message: ':x: Book publication failed!',
                      image_url: FAILURE_IMAGE_URL,
                      alt_text: 'Publication failed'),
        {
          type: 'section',
          text: {
            type: 'mrkdwn',
            text: "```#{details}```"
          }
        },
        {
          type: 'divider'
        },
        context
      ]
    end

    def standard_fields(book:) # rubocop:disable Metrics/MethodLength
      [
        {
          type: 'mrkdwn',
          text: "*Book*\n#{book&.title || '_unknown_'}"
        },
        {
          type: 'mrkdwn',
          text: "*SKU*\n`#{book&.sku || 'unknown'}`"
        },
        {
          type: 'mrkdwn',
          text: "*Edition*\n#{book&.edition || '_unknown_'}"
        },
        {
          type: 'mrkdwn',
          text: "*Environment*\n`#{ENVIRONMENT}`"
        }
      ]
    end

    def intro_section(book:, message:, image_url:, alt_text:) # rubocop:disable Metrics/MethodLength
      {
        type: 'section',
        text: {
          type: 'mrkdwn',
          text: message
        },
        fields: standard_fields(book: book),
        accessory: {
          type: 'image',
          image_url: image_url,
          alt_text: alt_text
        }
      }
    end

    def context # rubocop:disable Metrics/MethodLength
      {
        type: 'context',
        elements: [
          {
            type: 'image',
            image_url: ROBLES_CONTEXT_IMAGE_URL,
            alt_text: 'robles via razebot'
          },
          {
            type: 'mrkdwn',
            text: 'This is a message sent from *robles* via *razebot*.'
          }
        ]
      }
    end
  end
end
