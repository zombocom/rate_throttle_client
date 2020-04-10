require "test_helper"

module RateThrottleClient
  class ExponentialIncreaseProportionalRemainingDecreaseTest < Minitest::Test
    include ClientSharedTests
    def setup
      @klass = ExponentialIncreaseProportionalRemainingDecrease
    end

    def test_kwargs
      assert 42, @klass.new(decrease_divisor: 42).decrease_divisor
    end

    def test_remaining_sleep
      client_200 = @klass.new(start_sleep_for: 20)
      def client_200.jitter(_); 1; end
      def client_200.sleep(value); end
      client_200.call do
        FakeResponse.new(remaining: 200)
      end

      client_199 = @klass.new(start_sleep_for: 20)
      def client_199.jitter(_); 1; end
      def client_199.sleep(value); end
      client_199.call do
        FakeResponse.new(remaining: 199)
      end
      assert client_200.sleep_for < client_199.sleep_for
    end
  end
end
