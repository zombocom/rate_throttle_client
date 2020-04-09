$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
require "rate_throttle_client"

# require "minitest/autorun"

# https://github.com/seattlerb/minitest/issues/844
require "minitest"
Minitest.run

require 'rate_throttle_client/demo'

def fixture_path(path)
  Pathname.new(__dir__).join("fixtures").join(path)
end
