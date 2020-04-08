require "test_helper"

class RateThrottleClient::DemoTest < Minitest::Test

  def test_it_does_something_useful
    client = RateThrottleClient::Null.new
    demo = Demo.new(client: client, duration: 1)
    demo.call

    hash = demo.results

    assert_equal([0, 0, 0, 0, 0, 0, 0, 0, 0, 0], hash["max_sleep_val"])
    assert(hash["retry_ratio"], "Expected #{hash["retry_ratio"]} to exist in #{hash.inspect}, but it did not")
    assert(hash["request_count"], "Expected #{hash["request_count"]} to exist in #{hash.inspect}, but it did not")
    assert(demo.log_dir.directory?, "Expected #{demo.log_dir} to be a directory, but it was not")
    assert(demo.rackup_file.file?, "Expected #{demo.rackup_file} to be a file, but it was not")
  end
end
