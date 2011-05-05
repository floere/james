class SbbFinder
  
  def self.find(from, to, time)
    # TODO throw exception
  end
  
  def self.saved_response(from, to, time)
    res = response(from, to, time)
    save_response_in_file(res)
    res
  end
  
  def self.response(from, to, time)
    parameters = {
      :queryPageDisplayed   => "no",
      :REQ0JourneyStopsSA   => "1", # how from
      :REQ0JourneyStopsSG   => from.to_s, # from
      :REQ0JourneyStopsSID  => "",
      :REQ0JourneyStopsZA   => "1", # how to
      :REQ0JourneyStopsZG   => to.to_s, # to
      :REQ0JourneyStopsZID  => "",
      :REQ0JourneyDate      => sbb_date(time), # when date
      :REQ0JourneyTime      => sbb_time(time), # when time
      :REQ0HafasSearchForw  => "1", # forward
      :start => "Suchen"
    }
    url = "http://fahrplan.sbb.ch/bin/query.exe/dn?externalCall=yes"
    Net::HTTP.post_form(URI.parse(url), parameters)
  end
  
  def self.save_response_in_file(response)
    File.open('test.html', 'w') do |file|
      file.truncate 0
      file << response.body
    end
  end
  
  def self.sbb_date(date)
    days = {
      "Mon" => 'Mo',
      "Tue" => 'Di',
      "Wed" => 'Mi',
      "Thu" => 'Do',
      "Fri" => 'Fr',
      "Sat" => 'Sa',
      "Sun" => 'So'
    }
    sbb_date = date.strftime("%d.%m.%y")
    days.each do |key,value|
      sbb_date.sub!(/#{key}/, value)
    end
    sbb_date
  end

  def self.sbb_time(time)
    time.strftime("%H:%M")
  end
  
end