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

    def test_proportional_effect_on_sleep
      client_200_start = 200
      client_200 = @klass.new(starting_sleep_for: client_200_start)
      def client_200.sleep(value); end
      client_200.call do
        FakeResponse.new
      end

      client_400_start = 400
      client_400 = @klass.new(starting_sleep_for: client_400_start)
      def client_400.sleep(value); end
      client_400.call do
        FakeResponse.new
      end

      diff_200 = client_200_start - client_200.sleep_for
      diff_400 = client_400_start - client_400.sleep_for

      assert_in_delta(2 * diff_200, diff_400, 0.001, "Expected a 2x higher sleep value to decrease 2x faster (proportionally)")
    end
  end
end
