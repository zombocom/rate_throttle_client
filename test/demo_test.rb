require "test_helper"

class RateThrottleClient::DemoTest < Minitest::Test

  def test_it_does_something_useful
    client = RateThrottleClient::Null.new
    demo = Demo.new(client: client)
    assert(demo)
  end
end
