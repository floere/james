require File.expand_path '../../lib/james', __FILE__

class TimeDialogue
  include James::Dialogue

  hear 'What time is it?' => :time
  state :time do
    hear ['What time is it?', 'And now?'] => :time # TODO Sanity check that the target state exists!
    into { time = Time.now; "It is currently #{time.hour} #{time.min}." }
  end

end

# James.dialogue do
#
# end
#
# equals
#
# Class.new do
#   include James::Dialogue
#
# end