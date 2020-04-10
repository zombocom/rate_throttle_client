require "test_helper"

module RateThrottleClient
  class ExponentialIncreaseProportionalRemainingDecreaseTest < Minitest::Test
    include ClientSharedTests
    def setup
      @klass = ExponentialIncreaseGradualDecrease
    end

    def test_kwargs
      assert 42, @klass.new(decrease_divisor: 42).decrease_divisor
    end
  end
end
