# If using the gem, replace with:
#
# require 'rubygems'
# require 'james'
require File.expand_path '../../lib/james', __FILE__

James.dialog do

  hear 'Say goodbye' => :bye

  state :bye do
    into do
      "Arigato RubyKaeeghee, sayonara, and goodbye!"
    end
  end

end