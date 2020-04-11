module RateThrottleClient
  class ExponentialIncreaseProportionalDecrease < Base
    attr_accessor :decrease_divisor

    def initialize(*args, decrease_divisor: nil, **kargs)
      super(*args, **kargs)
      @decrease_divisor = (decrease_divisor || RateThrottleClient.max_limit).to_f
    end

    def call(&block)
      sleep_for = @sleep_for
      sleep(sleep_for + jitter(sleep_for))

      while (req = yield) && req.status == 429
        sleep_for += @min_sleep

        @log.call(Info.new(sleep_for: sleep_for, request: req))
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
  end
end
