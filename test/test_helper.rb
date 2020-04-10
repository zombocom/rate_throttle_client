$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
require "rate_throttle_client"

if defined?(M)
  # https://github.com/qrush/m/issues/80
  require "minitest"
else
  require "minitest/autorun"
end

require 'rate_throttle_client/demo'
require_relative "clients/shared_tests.rb"

def fixture_path(path)
  Pathname.new(__dir__).join("fixtures").join(path)
end

class FakeResponse
  attr_reader :status, :headers

  def initialize(status:  200, remaining:  10)
    @status = status

    @headers = {
      "RateLimit-Remaining" => remaining,
      "RateLimit-Multiplier" => 1,
      "Content-Type" => "text/plain".freeze
    }
  end
end

class FakeRetry
  def initialize(count: )
    @count = 0
    @retry_count = count
  end

  def call
    @count += 1
    if @count <= @retry_count
      FakeResponse.new(status: 429, remaining: 0)
    else
      FakeResponse.new(remaining: 1)
    end
  end
end
