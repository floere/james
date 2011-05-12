# If using the gem, replace with: require 'james'
#
require File.expand_path '../../lib/james', __FILE__

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