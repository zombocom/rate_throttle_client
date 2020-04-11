module RateThrottleClient
  # Actual exponential backoff class with some extra jazz so it reports
  # when sleep goes back to zero
  #
  # Essentially it doesn't throttle at all until it hits a 429 then it exponentially
  # throttles every repeatedly limited request. When it hits a successful request it stops
  # rate throttling again.
  class ExponentialBackoff < Base
    def call(&block)
      sleep_for = @min_sleep

      while (req = yield) && req.status == 429
        @log.call(Info.new(sleep_for: sleep_for, request: req))
        sleep(sleep_for + jitter(sleep_for))

        sleep_for *= @multiplier
      end

      # This no-op is needed to record that we've come out of a
      # retry state for the Demo class.
      sleep(0)

      req
    end
  end
end
