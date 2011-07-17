# If using the gem, replace with:
#
# require 'rubygems'
# require 'james'
require File.expand_path '../../lib/james', __FILE__

James.dialog do

  hear 'Open the door.' => :sorry

  state :sorry do
    into do
      "I'm sorry Dave. I'm afraid I can't do that."
    end
  end

end