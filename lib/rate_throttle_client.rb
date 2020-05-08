require "rate_throttle_client/version"
require "rate_throttle_client/info"

require 'thread'

module RateThrottleClient
  class Error < StandardError; end
  class << self
    attr_accessor :multiplier, :min_sleep, :max_limit, :log_block
  end
  self.log_block = ->(info) { warn "RateThrottleClient: sleep_for=#{info.sleep_for}" }
  self.max_limit = 4500.to_f
  self.min_sleep = 3600/max_limit
  self.multiplier = 1.2

  def self.config
    yield self
  end
end

require_relative 'rate_throttle_client/clients/base.rb'
Dir[File.dirname(__FILE__) + '/rate_throttle_client/clients/*.rb'].each { |file| require file }
