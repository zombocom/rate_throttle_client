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

RateThrottleClient.config do |config|
  config.log_block = ->(info){ }
end

MINUTE = 60
task :bench do
  duration = 30 * MINUTE
  clients = [
    RateThrottleClient::ExponentialBackoff,
    RateThrottleClient::ExponentialIncreaseGradualDecrease,
    RateThrottleClient::ExponentialIncreaseProportionalDecrease,
    RateThrottleClient::ExponentialIncreaseProportionalRemainingDecrease
  ]
  clients.each do |klass|
    begin
      client = klass.new
      demo = RateThrottleClient::Demo.new(client: client, duration: duration, time_scale: 10)
      demo.call
    ensure
      demo.print_results
      demo.chart(true)
    end

    begin
      workload = 4500
      starting_sleep = 1
      rackup_file = Pathname.new(__dir__).join("lib/rate_throttle_client/servers/decrease_only/config.ru")

      client = klass.new(starting_sleep_for: starting_sleep)
      demo = RateThrottleClient::Demo.new(client: client, time_scale: 10, starting_limit: 4500, duration: duration, remaining_stop_under: 10, rackup_file: rackup_file)

      before_time = Time.now
      demo.call
      diff = Time.now - before_time
    ensure
      puts
      puts "```"
      puts "Time to clear workload (#{workload} requests, starting_sleep: #{starting_sleep}s):"
      puts "#{"%.2f" % diff} seconds"
      puts "```"
      puts
    end
  end
end

task :charts do
  duration = 30 * MINUTE
  clients = [
    RateThrottleClient::ExponentialBackoff,
    RateThrottleClient::ExponentialIncreaseGradualDecrease,
    RateThrottleClient::ExponentialIncreaseProportionalDecrease,
    RateThrottleClient::ExponentialIncreaseProportionalRemainingDecrease
  ]
  clients.each do |klass|
    begin
      client = klass.new
      demo = RateThrottleClient::Demo.new(client: client, duration: duration, time_scale: 10)
      demo.call
    ensure
      demo.print_results
      demo.chart
    end
  end
end

