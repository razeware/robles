# frozen_string_literal: true

CI = ENV.fetch('CI', nil)
GITHUB_EVENT_NAME = ENV.fetch('GITHUB_EVENT_NAME', nil)
GITHUB_EVENT_PATH = ENV.fetch('GITHUB_EVENT_PATH', nil)
GITHUB_REPOSITORY = ENV.fetch('GITHUB_REPOSITORY', nil)
GITHUB_SHA = ENV.fetch('GITHUB_SHA', nil)
GITHUB_TOKEN = ENV.fetch('GITHUB_TOKEN', nil)
GITHUB_WORKSPACE = ENV.fetch('GITHUB_WORKSPACE', nil)
