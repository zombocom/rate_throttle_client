require "rate_throttle_client/version"
require "rate_throttle_client/info"

require 'thread'

module RateThrottleClient
  class Error < StandardError; end
  DEFAULT_LOG_BLOCK = log = ->(req, throttle) {}
  MAX_LIMIT = 4500.to_f
  MIN_SLEEP = 3600/MAX_LIMIT

  @clients = []
  def self.register_client(client)
    @clients << client
  end
end

Dir[File.dirname(__FILE__) + '/rate_throttle_client/clients/*.rb'].each { |file| require file }
