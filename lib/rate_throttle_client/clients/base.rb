module RateThrottleClient
  # Standard interface for Client classes
  # Don't abuse this power
  class Base
    attr_accessor :log, :minimum_sleep, :multiplier, :start_sleep_for, :sleep_for

    def initialize(log: DEFAULT_LOG_BLOCK,
      minimum_sleep: MIN_SLEEP,
      start_sleep_for: 0)
      @log = log
      @minimum_sleep = minimum_sleep
      @multiplier = MULTIPLIER
      @sleep_for = start_sleep_for
    end

    def jitter(val)
      val * rand(0.0..0.1)
    end
  end
end
