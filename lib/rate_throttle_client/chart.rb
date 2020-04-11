module RateThrottleClient
  class Chart
    def initialize(log_dir:, name:, time_scale:)
      @log_dir = log_dir
      @time_scale = time_scale
      @name = name
      @label_hash = nil
      @log_files = nil
    end

    def log_files
     @log_files ||= @log_dir.entries.map do |entry|
        @log_dir.join(entry)
      end.select do |file|
        file.basename.to_s.end_with?("-chart-data.txt")
      end
    end

    def get_line_count
      log_files.first.each_line.count
    end

    def label_hash(line_count = get_line_count)
      return @label_hash if @label_hash
      @label_hash = {}

      lines_per_hour = (3600.0 / @time_scale).floor

      line_tick = (line_count / 5.0).floor

      @label_hash[0] = "0"
      1.upto(5).each do |i|
        line_number = i * line_tick
        @label_hash[line_number - 1] = "%.2f" % (line_number.to_f / lines_per_hour)
      end

      @label_hash
    end

    def call(open_file = false)
      require 'gruff'

      graph = Gruff::Line.new()
      graph.title_font_size = 24

      graph.hide_legend = true if log_files.length > 10
      graph.title = "#{@name}\nSleep Values for #{log_files.count} clients"
      graph.x_axis_label = "Time duration in hours"
      graph.y_axis_label = "Sleep time in seconds"

      log_files.each do |entry|
        graph.data entry.basename.to_s.gsub("-chart-data.txt", ""), entry.each_line.map(&:to_f)
      end

      graph.labels = label_hash

      graph.write(file)

      `open #{file}` if open_file

      file
    end

    def file
      @log_dir.join('chart.png')
    end
  end
end
