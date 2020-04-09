$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
require "rate_throttle_client"

# require "minitest"
# https://github.com/seattlerb/minitest/pull/683#issuecomment-611302188
# Minitest.run
require "minitest/autorun"

require 'rate_throttle_client/demo'

def fixture_path(path)
  Pathname.new(__dir__).join("fixtures").join(path)
end
