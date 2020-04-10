require "test_helper"

module RateThrottleClient
  class DemoTest < Minitest::Test
    def setup
      @tmp_dir = Dir.mktmpdir
    end

    def teardown
      FileUtils.remove_entry @tmp_dir
    end

    def test_print_results
      dir = fixture_path("logs/90_sec_json_logs")
      demo = Demo.new(client: Null.new, log_dir: dir)

      io = StringIO.new
      demo.print_results(io)

      assert_match("retry_ratios: [0.10, 0.37, 0.10, 0.22, 0.35, 0.11, 0.11, 0.11, 0.12, 0.29]", io.string)
    end

    def test_time_scale
      client = Object.new
      def client.call
        sleep 1
        yield
      end
      demo = Demo.new(client: client, duration: 4, starting_limit: 4500, process_count: 1, thread_count: 1, log_dir: @tmp_dir)
      demo.call

      hash = demo.results
      request_count_no_time_scale = hash["request_count"].sum


      Dir.mktmpdir do |tmp_dir_2|
        demo = Demo.new(client: client, duration: 4, time_scale: 10, starting_limit: 4500, process_count: 1, thread_count: 1, log_dir: tmp_dir_2)
        demo.call

        hash = demo.results
        request_count = hash["request_count"].sum
        assert_equal(request_count_no_time_scale, request_count)
      end
    end

    def test_duration
      # TODO
    end

    def test_remaining_stop_under
      Dir.mktmpdir do |tmp_dir|
        tmp_file = File.join(tmp_dir, "config.ru")
        File.open(tmp_file, "w+") do |f|
          f.write(%Q{
            @remaining = 100

            app = Proc.new do |env|
              @remaining -= 1
              result = [200, {"Content-Type" => "text/plain", "RateLimit-Remaining" => @remaining}, ["I don't need this part!"]]
            end
            run app
          })
        end
        client = RateThrottleClient::Null.new
        demo = Demo.new(client: client, duration: 10**100, process_count: 1, thread_count: 1, remaining_stop_under: 10, rackup_file: tmp_file, log_dir: @tmp_dir)
        demo.call

        hash = demo.results
        assert_equal(90, hash["request_count"].sum)
      end
    end

    def test_rackup_file
      Dir.mktmpdir do |tmp_dir|
        tmp_file = File.join(tmp_dir, "config.ru")
        File.open(tmp_file, "w+") do |f|
          f.write(%Q{
            app = Proc.new do |env|
              [200, {"Content-Type" => "text/plain", "RateLimit-Remaining" => "200"}, ["I don't need this part!"]]
            end
            run app
          })
        end

        client = RateThrottleClient::Null.new
        demo = Demo.new(client: client, duration: 1, process_count: 1, rackup_file: tmp_file, log_dir: @tmp_dir)
        demo.call

        hash = demo.results
        assert_equal([0.0, 0.0, 0.0, 0.0, 0.0], hash["retry_ratio"])
      end
    end

    def test_starting_limit
      client = RateThrottleClient::Null.new
      demo = Demo.new(client: client, duration: 1, process_count: 1, starting_limit: 10 ** 100, log_dir: @tmp_dir)

      demo.call

      hash = demo.results
      assert_equal([0.0, 0.0, 0.0, 0.0, 0.0], hash["retry_ratio"])
    end

    def test_stream_requests
      client = RateThrottleClient::Null.new
      demo = Demo.new(client: client, duration: 1, process_count: 1, stream_requests: true, log_dir: @tmp_dir)
      def demo.boot_process;
        run_client_single
      end

      stdout_old = $stdout
      stdout_stub = StringIO.new
      $stdout = stdout_stub

      demo.call

      assert_match 'status=429', stdout_stub.string
    ensure
      $stdout = stdout_old
    end

    def test_log_dir
      client = RateThrottleClient::Null.new
      demo = Demo.new(client: client, duration: 1, log_dir: @tmp_dir)
      demo.call

      clients = Dir[File.join(@tmp_dir, "*.json")]
      assert_equal 10, clients.count
    end

    def test_calls_null
      client = RateThrottleClient::Null.new
      demo = Demo.new(client: client, duration: 1, log_dir: @tmp_dir)
      demo.call

      assert(demo.log_dir.directory?, "Expected #{demo.log_dir} to be a directory, but it was not")
      assert(demo.rackup_file.file?, "Expected #{demo.rackup_file} to be a file, but it was not")

      hash = demo.results

      assert(hash["request_count"],"Expected #{"request_count"} to exist in #{hash.inspect}, but it did not")
      assert(hash["retry_ratio"], "Expected #{"retry_ratio"} to exist in #{hash.inspect}, but it did not")

      assert_equal([0, 0, 0, 0, 0, 0, 0, 0, 0, 0], hash["max_sleep_val"])

      assert(hash["retry_ratio"].all? {|ratio| ratio > 0.5}, "Expected retry ratio of #{client.class} to all be above 0.5 but was #{hash["retry_ratio"]}")
    end

    def test_process_count
      number = rand(2..200)

      client = RateThrottleClient::Null.new
      demo = Demo.new(client: client, duration: 1, process_count: number, log_dir: @tmp_dir)
      def demo.boot_process; @boot_process_call_count ||= 0; @boot_process_call_count += 1; end

      demo.call

      assert_equal number, demo.instance_variable_get(:"@boot_process_call_count")
    end

    def test_thread_count
      number = rand(2..20)

      client = RateThrottleClient::Null.new
      demo = Demo.new(client: client, duration: 1, process_count: 1, thread_count: number, log_dir: @tmp_dir)

      demo.call

      clients = Dir[demo.log_dir.join("*.json")]
      assert_equal number, clients.count
    end

    def test_results_parsing
      dir = fixture_path("logs/90_sec_json_logs")
      demo = Demo.new(client: Object.new, log_dir: dir)

      expected = {"max_sleep_val"=>[53.88212537937639, 53.88212537937639, 53.88212537937639, 53.88212537937639, 53.88212537937639, 56.069378305278775, 56.069378305278775, 56.069378305278775, 56.069378305278775, 56.069378305278775], "retry_ratio"=>[0.10144927536231885, 0.36627906976744184, 0.10294117647058823, 0.21686746987951808, 0.35036496350364965, 0.1111111111111111, 0.10606060606060606, 0.10606060606060606, 0.125, 0.29464285714285715], "request_count"=>[69, 172, 68, 83, 137, 63, 66, 66, 72, 112]}
      assert_equal(expected, demo.results)
    end
  end
end
