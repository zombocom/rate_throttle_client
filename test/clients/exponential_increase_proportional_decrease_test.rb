require "test_helper"

module RateThrottleClient
  class ExponentialIncreaseProportionalDecreaseTest < Minitest::Test
    include ClientSharedTests
    def setup
      @klass = ExponentialIncreaseProportionalDecrease
    end

    def test_kwargs
      assert 42, @klass.new(decrease_divisor: 42).decrease_divisor
    end
  end
end
