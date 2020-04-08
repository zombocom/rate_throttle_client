require "test_helper"

class RateThrottleClientTest < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::RateThrottleClient::VERSION
  end
end
