module RateThrottleClient
  class Null
    def initialize(*_, **_)
    end

    def call
      yield
    end
  end
end

