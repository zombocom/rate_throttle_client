module RateThrottleClient
  class ExponentialIncreaseGradualDecrease < Base
    attr_accessor :decrease

    def initialize(*args, decrease: nil, **kargs)
      super(*args, **kargs)
      @decrease = decrease || @min_sleep
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

      if sleep_for >= @decrease
        sleep_for -= @decrease
      else
        sleep_for = 0
      end

      @sleep_for = sleep_for

      req
    end
  end
end
