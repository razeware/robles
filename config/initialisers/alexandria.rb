# frozen_string_literal: true

ALEXANDRIA_BASE_URL = ENV.fetch('ALEXANDRIA_BASE_URL', nil)
# robles's API v2 token, which starts with `kst_` (WEB-8205, WEB-8208). Any other
# value is refused before a publish (WEB-8371).
ALEXANDRIA_SERVICE_API_TOKEN = ENV.fetch('ALEXANDRIA_SERVICE_API_TOKEN', nil)
