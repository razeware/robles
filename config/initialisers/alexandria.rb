# frozen_string_literal: true

ALEXANDRIA_BASE_URL = ENV.fetch('ALEXANDRIA_BASE_URL', nil)
# A value that starts with `kst_` is robles's API v2 token and publishes through
# /api/v2 (WEB-8205, WEB-8208). Anything else is the shared token and uses v1.
ALEXANDRIA_SERVICE_API_TOKEN = ENV.fetch('ALEXANDRIA_SERVICE_API_TOKEN', nil)
