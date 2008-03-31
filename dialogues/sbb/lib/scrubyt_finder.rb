require 'sbb_finder'
require 'rubygems'
require 'scrubyt'

class ScrubytFinder < SbbFinder
  
  def self.find(from, to, datetime)
    date = sbb_date(datetime)
    time = sbb_time(datetime)
    sbb_data = Scrubyt::Extractor.define do
      # navigate to page
      fetch 'http://fahrplan.sbb.ch/bin/query.exe/dn?externalCall=yes'
      fill_textfield 'REQ0JourneyStopsS0G', from # from
      fill_textfield 'REQ0JourneyStopsZ0G', to # to
      # TODO set select to haltestelle
      fill_textfield 'REQ0JourneyDate', date
      fill_textfield 'REQ0JourneyTime', time
      # submit form
      submit
      # click_link '» Verbindung suchen'
      
      # # navigate to page
      # fetch 'http://fahrplan.sbb.ch/bin/query.exe/dn?externalCall=yes'
      # fill_textfield 'REQ0JourneyStopsS0G', 'geneva' # from
      # fill_textfield 'REQ0JourneyStopsZ0G', 'berne' # to
      # # TODO set select to haltestelle
      # fill_textfield 'REQ0JourneyDate', 'Mi, 07.02.07'
      # fill_textfield 'REQ0JourneyTime', '13:00'
      # # submit form
      # submit
      
      # submit again
      # submit
      
      # # start scraping
      # puts 'start scraping'
      # fahrplan "/html/body/div[3]/table/tbody/tr/td[3]/table[3]/tbody/tr/td/form/table/tbody", { :generalize => true } do
      #   departure "/tr[2]/td[5]", { :generalize => true }
      #   arrival "/tr[3]/td[4]", { :generalize => true }
      #   # dauer "/tr[2]/td[8]"
      # end
      
      # start scraping
      puts 'start scraping'
      fahrplan do
        departure '12:45'
        arrival '14:26'
        duration '1:41'
      end
      
    end
    # test output
    puts "text output:"
    sbb_data.to_xml.write($stdout, 1)
  end
  
end
