# If using the gem, replace with:
#
# require 'rubygems'
# require 'james'
require File.expand_path '../../lib/james', __FILE__

# iTunes dialog by Florian Hanke.
#
# This is a very simple James example.
#
James.dialog do

  hear "How about some music?" => :itunes

  state :itunes do
    hear 'Previous track' => ->() do
      `osascript -e 'tell application "iTunes"' -e "previous track" -e "end tell"`
      "Going to previous track, Sir."
    end
    hear 'Next track' => ->() do
      `osascript -e 'tell application "iTunes"' -e "next track" -e "end tell"`
      "Going to next track, Sir."
    end
    hear 'Stop track' => ->() do
      `osascript -e 'tell application "iTunes" to stop'`
      "Stopping current track, Sir."
    end
    hear 'Play track' => ->() do
      `osascript -e 'tell application "iTunes" to play'`
      "Playing current track, Sir."
    end
  end

end