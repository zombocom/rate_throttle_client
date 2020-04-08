module RateThrottleClient
  class ExponentialIncreaseProportionalDecrease
    def initialize(log: DEFAULT_LOG_BLOCK, sleep_for: 0)
      @minimum_sleep = MIN_SLEEP
      @decrease_divisor = MAX_LIMIT
      @multiplier = 1.2
      @log = log
      @sleep_for = sleep_for
    end

    def call(&block)
      sleep_for = @sleep_for
      sleep(sleep_for + jitter(sleep_for))

      while (req = yield) && req.status == 429
        sleep_for += @minimum_sleep

        log.call(req, RateThrottleInfo.new(sleep_for: sleep_for))

        sleep(sleep_for + jitter(sleep_for))
        sleep_for *= @multiplier
      end

      decrease_value = sleep_for / @decrease_divisor

      if sleep_for >= decrease_value
        sleep_for -= decrease_value
      else
        sleep_for = 0
      end

      @sleep_for = sleep_for

      req
    end

    def jitter(sleep_for)
      sleep_for * rand(0.0..0.1)
    end
  end
end
