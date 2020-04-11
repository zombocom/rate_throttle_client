module RateThrottleClient
  # Standard interface for Client classes
  # Don't abuse this power
  class Base
    attr_accessor :log, :min_sleep, :multiplier, :sleep_for

    def initialize(log: nil, min_sleep: nil, starting_sleep_for: 0, multiplier: nil)
      @log = log || RateThrottleClient.log_block
      @min_sleep = min_sleep || RateThrottleClient.min_sleep
      @multiplier = multiplier || RateThrottleClient.multiplier
      @sleep_for = starting_sleep_for
    end

    def jitter(val)
      val * rand(0.0..0.1)
    end
  end
end
