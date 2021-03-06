# frozen_string_literal: true

module Util
  # Adds methods that allow slack notifications
  module SlackNotifiable # rubocop:disable Metrics/ModuleLength
    extend ActiveSupport::Concern

    BOOK_SUCCESS_IMAGE_URL = 'https://wolverine.raywenderlich.com/v3-resources/razebot/images/object_textkit-book.png'
    VIDEO_COURSE_SUCCESS_IMAGE_URL = 'https://wolverine.raywenderlich.com/v3-resources/razebot/images/device-device_ui-flow-chart.png'
    FAILURE_IMAGE_URL = 'https://wolverine.raywenderlich.com/v3-resources/razebot/images/object_errors.png'
    BOOK_ROBLES_CONTEXT_IMAGE_URL = 'https://wolverine.raywenderlich.com/v3-resources/razebot/images/object_box-of-books.png'
    VIDEO_COURSE_ROBLES_CONTEXT_IMAGE_URL = 'https://wolverine.raywenderlich.com/v3-resources/razebot/images/object-box-videos.png'

    def notify_book_success(book:)
      return unless notifiable?

      notifier.post(blocks: book_success_blocks(book: book))
    end

    def notify_book_failure(book:, details: nil)
      return unless notifiable?

      notifier.post(blocks: book_failure_blocks(book: book, details: details || 'N/A'))
    end

    def notify_video_course_success(video_course:)
      return unless notifiable?

      notifier.post(blocks: video_course_success_blocks(video_course: video_course))
    end

    def notify_video_course_failure(video_course:, details: nil)
      return unless notifiable?

      notifier.post(blocks: video_course_failure_blocks(video_course: video_course, details: details || 'N/A'))
    end

    def notifiable?
      SLACK_WEBHOOK_URL.present?
    end

    def notifier
      @notifier ||= Slack::Notifier.new(SLACK_WEBHOOK_URL, channel: SLACK_CHANNEL, username: SLACK_USERNAME)
    end

    def book_success_blocks(book:)
      [
        intro_section(fields: standard_book_fields(book: book),
                      message: ':white_check_mark: Book publication successful!',
                      image_url: BOOK_SUCCESS_IMAGE_URL,
                      alt_text: 'Publication successful'),
        {
          type: 'divider'
        },
        context(BOOK_ROBLES_CONTEXT_IMAGE_URL)
      ]
    end

    def book_failure_blocks(book:, details:) # rubocop:disable Metrics/MethodLength
      [
        intro_section(fields: standard_book_fields(book: book),
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
        context(BOOK_ROBLES_CONTEXT_IMAGE_URL)
      ]
    end

    def video_course_success_blocks(video_course:)
      [
        intro_section(fields: standard_video_course_fields(video_course: video_course),
                      message: ':white_check_mark: Video course upload successful!',
                      image_url: VIDEO_COURSE_SUCCESS_IMAGE_URL,
                      alt_text: 'Upload successful'),
        {
          type: 'divider'
        },
        context(VIDEO_COURSE_ROBLES_CONTEXT_IMAGE_URL)
      ]
    end

    def video_course_failure_blocks(video_course:, details:) # rubocop:disable Metrics/MethodLength
      [
        intro_section(fields: standard_video_course_fields(video_course: video_course),
                      message: ':x: Video course upload failed!',
                      image_url: FAILURE_IMAGE_URL,
                      alt_text: 'Upload failed'),
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
        context(VIDEO_COURSE_ROBLES_CONTEXT_IMAGE_URL)
      ]
    end

    def standard_book_fields(book:) # rubocop:disable Metrics/MethodLength
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

    def standard_video_course_fields(video_course:) # rubocop:disable Metrics/MethodLength
      [
        {
          type: 'mrkdwn',
          text: "*Video Course*\n#{video_course&.title || '_unknown_'}"
        },
        {
          type: 'mrkdwn',
          text: "*Short Code*\n`#{video_course&.shortcode || 'unknown'}`"
        },
        {
          type: 'mrkdwn',
          text: "*Version*\n#{video_course&.version || '_unknown_'}"
        },
        {
          type: 'mrkdwn',
          text: "*Environment*\n`#{ENVIRONMENT}`"
        }
      ]
    end

    def intro_section(fields:, message:, image_url:, alt_text:) # rubocop:disable Metrics/MethodLength
      {
        type: 'section',
        text: {
          type: 'mrkdwn',
          text: message
        },
        fields: fields,
        accessory: {
          type: 'image',
          image_url: image_url,
          alt_text: alt_text
        }
      }
    end

    def context(image) # rubocop:disable Metrics/MethodLength
      {
        type: 'context',
        elements: [
          {
            type: 'image',
            image_url: image,
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
