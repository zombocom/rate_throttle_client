require "test_helper"

module RateThrottleClient
  class ExponentialIncreaseGradualDecreaseTest < Minitest::Test
    include ClientSharedTests
    def setup
      @klass = ExponentialIncreaseGradualDecrease
    end

    def test_kwargs
      assert 42, @klass.new(decrease: 42).decrease
    end
  end
end
