require "test_helper"

module RateThrottleClient
  class NullTest < Minitest::Test
    def test_gets_called
      client = Null.new

      @called_count = 0
      client.call do
        @called_count += 1
      end

      assert_equal 1, @called_count
    end
  end
end
