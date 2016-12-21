module WelcomeHelper
  def _replies_timeline_data_csv(replies_timeline_data)
    # Get times and sort
    date_times = replies_timeline_data.to_a.map{|d| DateTime.parse(d[:time]).to_i}.uniq.sort
    counts_map = {
      -1 => Hash.new(0),
      0 => Hash.new(0),
      1 => Hash.new(0)
    }

    replies_timeline_data.to_a.each do |d|
      counts_map[d[:sentiment]][DateTime.parse(d[:time]).to_i] = d[:count]
    end
    Rails.logger.info counts_map
    result = _build_time_values_row(date_times)

    result += "\nNegative," + date_times.map{|d| counts_map[-1][d] }.join(',')
    result += "\nNeutral," + date_times.map{|d| counts_map[0][d] }.join(',')
    result += "\nPositive," + date_times.map{|d| counts_map[1][d]  }.join(',')

    result
  end

  def _build_time_values_row(date_times)
    result = 'Time'
    date_times.each do |d|
      d = Time.at(d).to_datetime
      if (d.hour == 0)
        result += "," + d.strftime('%b %d')
      else
        result += "," + d.strftime('%H:00')
      end
    end

    result
  end
end
