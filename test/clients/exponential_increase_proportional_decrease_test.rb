require "test_helper"

module RateThrottleClient
  class ExponentialIncreaseProportionalDecreaseTest < Minitest::Test
    def test_gets_called
      client = ExponentialIncreaseProportionalDecrease.new

      @called_count = 0
      client.call do
        @called_count += 1
        FakeResponse.new
      end

      assert_equal 1, @called_count
    end
  end
end
