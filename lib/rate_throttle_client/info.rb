module RateThrottleClient

  # Class used for reporting
  class Info
    attr_reader :sleep_for

    def initialize(sleep_for: )
      @sleep_for = sleep_for
    end
  end
end
