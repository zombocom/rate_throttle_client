module RateThrottleClient
  class Null < Base
    def initialize(*_, **_)
    end

    def call
      yield
    end
  end
end

