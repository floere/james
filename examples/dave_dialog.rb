# If using the gem, replace with:
#
# require 'rubygems'
# require 'james'
require File.expand_path '../../lib/james', __FILE__

James.dialog do

  hear 'James, I am going to close you now.' => :dave

  state :dave do
    into do
      "I'm sorry Dave, I can't let you do that."
    end
  end

end