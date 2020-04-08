require 'thread'

if ENV["TIME_SCALE"]
  require 'timecop'
  Timecop.scale(ENV["TIME_SCALE"].to_f)
end

module RateThrottleClient
  class GcraFakeServer
    MAX_REQUESTS = 4500
    RATE_OF_LIMIT_GAIN = MAX_REQUESTS / 3600.to_f

    def initialize(starting_limit: 0)
      @limit_left = starting_limit.to_f
      @mutex = Mutex.new
    end

    def call(_)
      @last_request ||= Time.now
      headers = nil
      successful_request = false

      @mutex.synchronize do
        if @limit_left < MAX_REQUESTS
          current_request = Time.now
          time_diff = current_request - @last_request
          @last_request = current_request

          @limit_left = [@limit_left + time_diff * RATE_OF_LIMIT_GAIN, MAX_REQUESTS].min
        end

        if @limit_left >= 1
          @limit_left -= 1
          successful_request = true
        end

        headers = { "RateLimit-Remaining" => [@limit_left.floor, 0].max, "RateLimit-Multiplier" => 1, "Content-Type" => "text/plain".freeze }
      end


      if !successful_request
        status = 429
        body = "!!!!! Nope !!!!!".freeze
      else
        status = 200
        body = "<3<3<3 Hello world <3<3<3".freeze
      end

      return [status, headers, [body]]
    end
  end
end
