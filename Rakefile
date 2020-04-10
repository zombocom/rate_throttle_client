require "bundler/gem_tasks"
require "rake/testtask"

Rake::TestTask.new(:test) do |t|
  t.libs << "test"
  t.libs << "lib"
  t.test_files = FileList["test/**/*_test.rb"]
end

task :default => :test


$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
require "rate_throttle_client"
require 'rate_throttle_client/demo'

MINUTE = 60
task :bench do
  duration = 30 * MINUTE
  clients = [
    RateThrottleClient::ExponentialBackoff.new,
    RateThrottleClient::ExponentialIncreaseGradualDecrease.new,
    RateThrottleClient::ExponentialIncreaseProportionalDecrease.new,
    RateThrottleClient::ExponentialIncreaseProportionalRemainingDecrease.new
  ]
  clients.each do |client|
    begin
      demo = RateThrottleClient::Demo.new(client: client, duration: duration, time_scale: 10)
      demo.call
    ensure
      demo.print_results
    end
  end
end