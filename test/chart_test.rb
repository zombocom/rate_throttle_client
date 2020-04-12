require "test_helper"

module RateThrottleClient
  class ChartTest < Minitest::Test
    def test_making_a_chart_works
      dir = fixture_path("logs/prop_dec")
      chart = RateThrottleClient::Chart.new(log_dir: dir, name: "ProportionalDecrease", time_scale: 1)

      chart.log_files.each do |file|
        assert file.file?
      end

      assert_equal 180, chart.get_line_count
      assert_equal 10, chart.log_files.count
      assert_equal({0=>"0", 35=>"0.01", 71=>"0.02", 107=>"0.03", 143=>"0.04", 179=>"0.05"}, chart.label_hash)

      chart.file.delete if chart.file.file?

      chart.call()

      assert chart.file.file?
    end
  end
end
