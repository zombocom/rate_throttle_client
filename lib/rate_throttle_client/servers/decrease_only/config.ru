require 'timecop'
require 'rate_throttle_client'

if ENV["TIME_SCALE"]
  require 'timecop'
  Timecop.scale(ENV["TIME_SCALE"].to_f)
end

module RateThrottleClient
  # This server does not gain new requests over time
  # it's main purpose is to benchmark how long it takes to
  # clear a fixed sized workload
  class NullFakeServer

    def initialize(starting_limit: 0)
      @limit_left = starting_limit.to_f
      @mutex = Mutex.new
    end

    def call(_)
      headers = nil
      successful_request = false

      @mutex.synchronize do
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

starting_limit = ENV.fetch("STARTING_LIMIT", 0).to_i
run RateThrottleClient::NullFakeServer.new(starting_limit: starting_limit)

