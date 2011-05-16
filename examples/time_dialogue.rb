# If using the gem, replace with:
#
# require 'rubygems'
# require 'james'
require File.expand_path '../../lib/james', __FILE__

# Time dialogue by Florian Hanke.
#
# This is a very simple James example.
#
# It has only one state, :time, and a single
# entry/hook phrase, "What time is it?"
#
# How could you enhance it to answer "What date is it?" ?
#
class TimeDialogue

  include James::Dialogue

  hear 'What time is it?' => :time
  state :time do
    hear ['What time is it?', 'What time is it now?'] => :time
    into do
      time = Time.now
      "It is currently #{time.hour} #{time.min}."
    end
  end

end

James.listen
