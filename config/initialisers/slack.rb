# frozen_string_literal: true

SLACK_WEBHOOK_URL = ENV.fetch('SLACK_WEBHOOK_URL', nil)
SLACK_CHANNEL = ENV['SLACK_CHANNEL'] || '#robles'
SLACK_USERNAME = ENV['SLACK_USERNAME'] || 'razebot'
