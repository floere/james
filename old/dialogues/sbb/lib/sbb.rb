require 'net/http'
require 'uri'
require 'hpricot_finder'
require 'rubygems'

class Sbb
  
  # returns an array with hashes with keys departure, arrival
  def self.find(from = 'Berne', to = 'Geneva', time = Time.now)
    puts "finding with #{from}, #{to}, #{time}"
    # use hpricot - still the best
    HpricotFinder.find(from, to, time)
  end
  
end