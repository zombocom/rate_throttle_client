module RateThrottleClient
  module ClientSharedTests
    def test_gets_called
      client = @klass.new
      def client.sleep(val); end

      @called_count = 0
      response = client.call do
        @called_count += 1
        FakeResponse.new
      end

      assert_equal 1, @called_count
      assert_equal 200, response.status

      @called_count = 0
      response = client.call do
        @called_count += 1
        @response ||= FakeRetry.new(count: 1)
        @response.call
      end
      assert_equal 2, @called_count
      assert_equal 200, response.status
    end

    def test_log_block_is_called
      @log_called = 0
      log = -> (info) {
        @log_called += 1
        assert info.sleep_for
        assert info.request
      }
      client = @klass.new(log: log)
      def client.sleep(value); end

      client.call do
        @response ||= FakeRetry.new(count: 1)
        @response.call
      end

      # Null never calls log since it never retries
      # We still want to test the interface
      assert_equal 1, @log_called unless @klass == Null
    end

    def test_log_is_setable_via_accessor
      @log_called = 0
      client = @klass.new()
      client.log = -> (info) { @log_called += 1 }
      def client.sleep(value); end

      client.call do
        @response ||= FakeRetry.new(count: 1)
        @response.call
      end

      # Null never calls log since it never retries
      # We still want to test the interface
      assert_equal 1, @log_called unless @klass == Null
    end
  end
end
