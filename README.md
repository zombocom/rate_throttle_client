# RateThrottleClient

Rate limiting is for servers, rate throttling is for clients. This library implements a number of strategies for handling rate throttling on the client and a methodology for comparing performance of those clients. We don't just give you the code to rate throttle, we also give you the information to help you figure out the best strategy to rate throttle as well.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'rate_throttle_client'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install rate_throttle_client

## Usage

Wrap requests to an API endpoint using one of the provided rate throttling classes:

```ruby
throttle = RateThrottleClient::ExponentialIncreaseProportionalRemainingDecrease.new

response = throttle.call do
  Excon.get("https://api.example.com")
end
```

If the server returns a `429` status (the HTTP code indicating that a server side rate limit has been reached) then the request will be retried according to the classes' strategy.

## Expected return value from call

If you're not using Excon to build your API client, then you'll need to make sure the object returned to the block responds to `status` (returning the status code). To use `ExponentialIncreaseProportionalRemainingDecrease` it's expected that `headers["RateLimit-Remaining"].to_i` returns the number of available requests capacity.

### Config

```ruby
RateThrottleClient.config do |config|
  config.log_block = ->(info){ puts "I get called when rate throttling is triggered #{info.sleep_for} #{info.request}" }
  config.max_limit = 4500.to_f # Maximum number of requests available
  config.multiplier = 1.2 # When rate limiting happens, this is amount to the sleep value is increased by
end
```

## Strategies

This library has a few strategies you can choose between:

- RateThrottleClient::ExponentialBackoff
- RateThrottleClient::ExponentialIncreaseGradualDecrease
- RateThrottleClient::ExponentialIncreaseProportionalDecrease
- RateThrottleClient::ExponentialIncreaseProportionalRemainingDecrease

To choose, you need to understand what makes a "good" throttling strategy, and then you need some benchmarks.

## What Makes a Good Rate Throttle strategy?

- Minimize retry ratio: For example if every 50 successful requests, the client hits a rate limited request the ratio of retries is 1/50 or 2%. Why minimize this value? It takes CPU and Network resources to make requests that fail, if the client is making requests that are being limited, it's using resources that could be better spent somewhere else. The server also benefits as it spends less time dealing with rate limiting. (Tracked via Avg retry rate)
- Minimize standard deviation of request count across the system: If there are two clients and one client is throttling by sleeping for 100 seconds and the other is throttling for 1 second, the distribution of requests are not equitable. Ideally over time each client might go up or down, but both would see a median of 50 seconds of sleep time. Why? If processes in a system have a high variance, one process is starved for API resources. It then becomes difficult to balance or optimize otherworkloads. When a client is stuck waiting on the API, ideally it can perform other operations (for example in other threads). If one process is using 100% of CPU and slamming the API and other is using 1% of CPU and barely touching the API, it is difficult to balance the workloads. (Tracked via Stdev Request Count)
- Minimize sleep/wait time: Retry ratio can be improved artificially by choosing high sleep times. In the real world consumers don't want to wait longer than absolutely necessarry. While a client might be able to "work steal" while it is sleeping/waiting, there's not guarantee that's the case. Essentially assume that any amount of time spent sleeping over the minimum amount of time required is wasted. This value is calculateable, but that calculation requires complete information of the distributed system. (Tracked via Max sleep time)
  - At many available requests: It should be able to consume all available requests: If a server allows 100,000 requests in a day then a client should be capable of making 100,000 requests. If the rate limiting algorithm only allows it to make 100 requests it would have low retry ratio but high wait time.
  - At few available requests: If clients do not sleep enough their retry rate will be very high, if they sleep too much then they they are not are using available resources.
- Minimize time to respond to a change in available requests to either slow down or speed up rate throttling: A change can happen when clients are added or removed (for example if the number of servers/dynos are scaled up or down). It can also happen naturally if processing in a background worker or a web endpoint where the workload is cyclical. If there are few requests available and many become available, the rate throttle algorithm should adjust to match the new availability quickly. (Tracked via Time to clear workload)

The only strategy that handles all these scenarios well is currently: `RateThrottleClient::ExponentialIncreaseProportionalRemainingDecrease` against a [GCRA rate limit strategy, such as the one implemented by the Heroku API]().

## Pretty Chart

Here's a simulated run with the `ExponentialIncreaseProportionalRemainingDecrease` strategy with 10 clients (2 processes, 5 threads each) against a GCRA server for half an hour:

![](https://www.dropbox.com/s/2zda4v7jr07xy9d/2020-04-21-10-59-1587484779-399584000-RateThrottleClient%3A%3AExponentialIncreaseProportionalRemainingDecrease-chart.png?raw=1)

> A calculated optimal sleep time average for the system would be 8 seconds per client (arrival rate of new request capacity is 0.8 seconds, and there are 10 clients), this strategy oscilates around that value without needing complete information about the distributed system.

To generate a chart for all strategies run `rake bench`.

## Benchmarks

These benchmarks are generated by running `rake bench` against the simulated "[GCRA](https://brandur.org/rate-limiting)" rate limiting server.

**Lower values are better**

### RateThrottleClient::ExponentialBackoff results (duration: 30.0 minutes, multiplier: 1.2)

```
Avg retry rate:      80.41 %
Max sleep time:      46.72 seconds
Stdev Request Count: 147.84

Raw max_sleep_vals: [46.72, 46.72, 46.72, 46.72, 46.72, 46.50, 46.50, 46.50, 46.50, 46.50]
Raw retry_ratios: [0.79, 0.79, 0.81, 0.82, 0.80, 0.80, 0.79, 0.81, 0.82, 0.81]
Raw request_counts: [1317.00, 1314.00, 1015.00, 963.00, 1254.00, 1133.00, 1334.00, 1025.00, 1024.00, 1036.00]
```

```
Time to clear workload (4500 requests, starting_sleep: 1s):
74.33 seconds
```

### RateThrottleClient::ExponentialIncreaseGradualDecrease results (duration: 30.0 minutes, multiplier: 1.2)

```
Avg retry rate:      40.56 %
Max sleep time:      139.91 seconds
Stdev Request Count: 867.73

Raw max_sleep_vals: [110.25, 110.25, 110.25, 110.25, 110.25, 139.91, 139.91, 139.91, 139.91, 139.91]
Raw retry_ratios: [0.46, 0.37, 0.38, 0.37, 0.39, 0.40, 0.41, 0.35, 0.37, 0.57]
Raw request_counts: [48.00, 57.00, 56.00, 49.00, 282.00, 85.00, 83.00, 79.00, 2821.00, 37.00]
```

```
Time to clear workload (4500 requests, starting_sleep: 1s):
115.54 seconds
```

### RateThrottleClient::ExponentialIncreaseProportionalDecrease results (duration: 30.0 minutes, multiplier: 1.2)

```
Avg retry rate:      3.66 %
Max sleep time:      17.31 seconds
Stdev Request Count: 101.94

Raw max_sleep_vals: [17.31, 17.31, 17.31, 17.31, 17.31, 17.21, 17.21, 17.21, 17.21, 17.21]
Raw retry_ratios: [0.01, 0.07, 0.03, 0.05, 0.06, 0.01, 0.07, 0.01, 0.03, 0.03]
Raw request_counts: [343.00, 123.00, 223.00, 144.00, 128.00, 348.00, 116.00, 383.00, 194.00, 203.00]
```

```
Time to clear workload (4500 requests, starting_sleep: 1s):
551.10 seconds
```

### RateThrottleClient::ExponentialIncreaseProportionalRemainingDecrease results (duration: 30.0 minutes, multiplier: 1.2)

```
Avg retry rate:      3.07 %
Max sleep time:      17.32 seconds
Stdev Request Count: 78.44

Raw max_sleep_vals: [12.14, 12.14, 12.14, 12.14, 12.14, 17.32, 17.32, 17.32, 17.32, 17.32]
Raw retry_ratios: [0.03, 0.02, 0.01, 0.02, 0.03, 0.03, 0.02, 0.05, 0.04, 0.07]
Raw request_counts: [196.00, 269.00, 386.00, 302.00, 239.00, 197.00, 265.00, 150.00, 187.00, 118.00]
```

```
Time to clear workload (4500 requests, starting_sleep: 1s):
84.23 seconds
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/rate_throttle_client. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/[USERNAME]/rate_throttle_client/blob/master/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the RateThrottleClient project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/rate_throttle_client/blob/master/CODE_OF_CONDUCT.md).
