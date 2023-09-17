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
    CONTENT_MODULE_ROBLES_CONTEXT_IMAGE_URL = 'https://wolverine.raywenderlich.com/v3-resources/razebot/images/object-box-content-module.png'

    def notify_book_success(book:)
      return unless notifiable?

      notifier.post(blocks: book_success_blocks(book:))
    end

    def notify_book_failure(book:, details: nil)
      return unless notifiable?

      notifier.post(blocks: book_failure_blocks(book:, details: details || 'N/A'))
    end

    def notify_video_course_success(video_course:)
      return unless notifiable?

      notifier.post(blocks: video_course_success_blocks(video_course:))
    end

    def notify_video_course_failure(video_course:, details: nil)
      return unless notifiable?

      notifier.post(blocks: video_course_failure_blocks(video_course:, details: details || 'N/A'))
    end

    def notify_content_module_success(content_module:)
      return unless notifiable?

      notifier.post(blocks: content_module_success_blocks(content_module:))
    end

    def notify_content_module_failure(content_module:, details: nil)
      return unless notifiable?

      notifier.post(blocks: content_module_failure_blocks(content_module:, details: details || 'N/A'))
    end

    def notifiable?
      SLACK_WEBHOOK_URL.present?
    end

    def notifier
      @notifier ||= Slack::Notifier.new(SLACK_WEBHOOK_URL, channel: SLACK_CHANNEL, username: SLACK_USERNAME)
    end

    def book_success_blocks(book:)
      [
        intro_section(fields: standard_book_fields(book:),
                      message: ':white_check_mark: Book publication successful!',
                      image_url: BOOK_SUCCESS_IMAGE_URL,
                      alt_text: 'Publication successful'),
        {
          type: 'divider'
        },
        context(BOOK_ROBLES_CONTEXT_IMAGE_URL)
      ]
    end

    def book_failure_blocks(book:, details:)
      [
        intro_section(fields: standard_book_fields(book:),
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
        intro_section(fields: standard_video_course_fields(video_course:),
                      message: ':white_check_mark: Video course upload successful!',
                      image_url: VIDEO_COURSE_SUCCESS_IMAGE_URL,
                      alt_text: 'Upload successful'),
        {
          type: 'divider'
        },
        context(VIDEO_COURSE_ROBLES_CONTEXT_IMAGE_URL)
      ]
    end

    def video_course_failure_blocks(video_course:, details:)
      [
        intro_section(fields: standard_video_course_fields(video_course:),
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

    def content_module_success_blocks(content_module:)
      [
        intro_section(fields: standard_content_module_fields(content_module:),
                      message: ':white_check_mark: Content module upload successful!',
                      image_url: CONTENT_MODULE_ROBLES_CONTEXT_IMAGE_URL,
                      alt_text: 'Upload successful'),
        {
          type: 'divider'
        },
        context(CONTENT_MODULE_ROBLES_CONTEXT_IMAGE_URL)
      ]
    end

    def content_module_failure_blocks(content_module:, details:)
      [
        intro_section(fields: standard_content_module_fields(content_module:),
                      message: ':x: Content module upload failed!',
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
        context(CONTENT_MODULE_ROBLES_CONTEXT_IMAGE_URL)
      ]
    end

    def standard_book_fields(book:)
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

    def standard_video_course_fields(video_course:)
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

    def intro_section(fields:, message:, image_url:, alt_text:)
      {
        type: 'section',
        text: {
          type: 'mrkdwn',
          text: message
        },
        fields:,
        accessory: {
          type: 'image',
          image_url:,
          alt_text:
        }
      }
    end

    def context(image)
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
