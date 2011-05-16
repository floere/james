# If using the gem, replace with:
#
# require 'rubygems'
# require 'james'
require File.expand_path '../../lib/james', __FILE__

# iTunes dialogue by Florian Hanke.
#
# This is a very simple James example.
#
# It has only one state, :time, and a single
# entry/hook phrase, "What time is it?"
#
# How could you enhance it to answer "What date is it?" ?
#
class ItunesDialogue

  include James::Dialogue

  hear 'Open iTunes and play' => :itunes
  state :itunes do
    hear 'Next track' => ->() do
      `osascript -e 'tell application "iTunes"' -e "next track" -e "end tell"`
      "Playing next track, Sir."
    end
    hear 'Previous track' => ->() do
      `osascript -e 'tell application "iTunes"' -e "previous track" -e "end tell"`
      "Playing previous track, Sir."
    end
    into do
      `osascript -e 'tell application "iTunes" to play'`
      "Opening i Tunes, Sir."
    end
  end

end

James.listen
