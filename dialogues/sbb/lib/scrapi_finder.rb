require 'sbb_finder'
require 'rubygems'
require 'scrapi'

class ScrapiFinder < SbbFinder
  
  def self.find(from, to, time)
    # get response
    res = response(from, to, time)
    # save response in file
    #save_response_in_file(res)
    # scrape
    scrape(res)
  end
  
  private
  
  def scrape(res)
    timetable_result = Scraper.define do
      process "td.result:nth-child(2)", :from => :text
      process "td.result:nth-child(1)", :to => :text
      process 'td.result:nth-child(5)', :departure => :text
      process "td.result:nth-child(9)", :arrival => :text
    end
    
    timetable = Scraper.define do
      array :results
      # html body div.posContent table trbody td.hafas table.hac_greybox tbody tr td.hac_greybox_cell form table.hafas-content tbody tr.zebra-row-0 td.result
      # process "html > body > div.posContentSubnav > table > trbody > td.hafas > table.hac_greybox > tbody > tr > td.hac_greybox_cell > form > table.hafas-content > tbody > tr.zebra-row-0 > td.result",
      process 'table.hafas-content tr.zebra-row-0', :results => timetable_result
      # process 'table.hafas-content tr[class^="zebra-row"]:nth-child(2)', :results => timetable_result
      # process 'table.hafas-content tr[class^="zebra-row"]:nth-child(4)', :results => timetable_result
      # process 'table.hafas-content tr[class^="zebra-row"]:nth-child(6)', :results => timetable_result
      result :results
    end
    result = timetable.scrape(res.body)
    # preprocess result
    clean_result(result)
  end
  
  def clean_result(result)
    # TODO
    if result.respond_to? :each
      result.each do |r|
        r.departure.gsub!(/&nbsp;/,'') if r.departure
      end
    else
      result.departure.gsub!(/&nbsp;/,'') if result.departure
    end
    result
  end
  
end