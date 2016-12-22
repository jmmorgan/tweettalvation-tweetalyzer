module WelcomeHelper
  def _replies_timeline_data_csv(replies_timeline_data)
    # Get date times for x axis
    date_times = _build_date_times_axis(replies_timeline_data)

    counts_map = {
      -1 => Hash.new(0),
      0 => Hash.new(0),
      1 => Hash.new(0)
    }

    replies_timeline_data.to_a.each do |d|
      counts_map[d[:sentiment]][DateTime.parse(d[:time]).to_i] = d[:count]
    end
    
    result = "Time,Positive,Neutral,Negative\n"

    date_times.each do |d|
      dt = Time.at(d).to_datetime
      if (dt.hour == 0)
        result += "#{dt.strftime('%b %d')},"
      else
        result += "#{dt.strftime('%H:00')},"
      end

      result += "#{counts_map[1][d]},#{counts_map[0][d]},#{counts_map[-1][d]}\n"
    end

    result
  end

  def _build_date_times_axis(replies_timeline_data)
    sorted_times = replies_timeline_data.to_a.map{|d| DateTime.parse(d[:time]).to_i}.uniq.sort

    max = sorted_times.last
    min = sorted_times.first

    # Append missing hours and resort
    next_hour = (min + 3600) - min % 3600
    while(next_hour < max)
      if(!sorted_times.include?(next_hour))
        sorted_times << next_hour
      end
      next_hour += 3600
    end

    sorted_times.sort
  end
end
