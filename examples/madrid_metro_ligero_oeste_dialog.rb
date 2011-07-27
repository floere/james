# MLO stands for the Metro Ligero Oeste, the tramway network for the west area of Madrid
# DiMLOrb (https://github.com/ariera/diMLOrb) is a gem to estimate conmutation times in the tramway network
# This James script asks the user for the origin and destination stations and informs him
# how much time he has before his train passes by.
#
# Be sure to
#   gem install diMLOrb
# first.
#
require 'DiMLOrb'

# By Alejandro Riera (http://github.com/ariera).
#
James.dialog do

  hear 'Madrid Metro' => :metro

  # Listen for each origin station in the MLO
  # network.
  #
  state :metro do
    DiMLOrb::STATIONS.keys.each do |station|
      hear station.to_s => "from_#{station}".to_sym
    end
    into {'from?'}
  end

  # Define one state for each origin station and
  # listen to the destination station.
  #
  DiMLOrb::STATIONS.keys.each do |station|
    state "from_#{station}".to_sym do
      DiMLOrb::STATIONS.keys.each do |st|
        hear st.to_s => "to_#{st}".to_sym
      end
      into {@origin = station; "from #{station}, to?"}
    end
  end

  # Define one state for each destination station
  # and calculate the time.
  #
  DiMLOrb::STATIONS.keys.each do |station|
    state "to_#{station.to_s}".to_sym do
      hear 'again'
      into do
        @destination = station
        d = DiMLOrb::DiMLOrb.new(@origin, @destination)
        "Next train from #{@origin} to #{@destination} is in #{d.proximo} minutes and then in #{d.siguiente} minutes, Sir."
      end
    end
  end

end