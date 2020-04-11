module RateThrottleClient

  # Class used for reporting
  class Info
    attr_reader :sleep_for, :request

    def initialize(sleep_for: , request: )
      @sleep_for = sleep_for
      @request = request
    end
  end
end
