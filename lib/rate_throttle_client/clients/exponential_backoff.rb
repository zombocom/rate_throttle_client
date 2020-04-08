module RateThrottleClient
  # Actual exponential backoff class with some extra jazz so it reports
  # when sleep goes back to zero
  #
  # Essentially it doesn't throttle at all until it hits a 429 then it exponentially
  # throttles every repeatedly limited request. When it hits a successful request it stops
  # rate throttling again.
  class ExponentialBackoff
    attr_reader :log

    def initialize(log: DEFAULT_LOG_BLOCK)
      @minimum_sleep = MIN_SLEEP
      @multiplier = 1.2
      @log = log
    end

    def call(&block)
      sleep_for = @minimum_sleep

      while (req = yield) && req.status == 429
        log.call(req, RateThrottleInfo.new(sleep_for: sleep_for))

        sleep(sleep_for + jitter(sleep_for))
        sleep_for *= @multiplier
      end

      sleep(0) # reset value for chart

      req
    end

    def jitter(sleep_for)
      sleep_for * rand(0.0..0.1)
    end
  end
end

