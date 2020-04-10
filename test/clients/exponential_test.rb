require "test_helper"

module RateThrottleClient
  class ExponentialBackoffTest < Minitest::Test
    include ClientSharedTests
    def setup
      @klass = ExponentialBackoff
    end
  end
end
