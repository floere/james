# If using the gem, replace with:
#
# require 'rubygems'
# require 'james'
require File.expand_path '../../lib/james', __FILE__

require 'rubygems'
require 'barometer'

# Weather dialogue by Florian Hanke.
#
# This is a very simple James example.
#
# Note: Currently it just a stub.
#
# Note 2: We need to enable Dialogue passing to James.listen
#         to make dialogues configurable a la WeatherDialogue.for("Paris").
#
class WeatherDialogue

  include James::Dialogue

  def initialize
    Barometer.config = { 1 => [:yahoo, :google], 2 => :wunderground }

    @barometer = Barometer.new "Melbourne"
  end

  hear 'How is the weather?' => :weather
  state :weather do
    hear ['How warm is it?', 'How cold is it?'] => ->(){ "It is #{@barometer.measure.current.temperature.celsius} degrees celsius" }
  end

end

James.listen
