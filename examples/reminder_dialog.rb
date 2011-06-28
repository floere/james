# If using the gem, replace with:
#
# require 'rubygems'
# require 'james'
require File.expand_path '../../lib/james', __FILE__

module PluralizedHour
  def pluralized_hour i
    "#{i} hour#{ 's' if i > 1 }"
  end
end

# Simple reminder dialog by Florian Hanke.
#
James.dialog do
  include PluralizedHour

  hear 'Set a reminder' => :reminder
  
  state :reminder do
    extend PluralizedHour
    
    10.downto(1).each do |i|
      hear "Remind me in #{pluralized_hour(i)}" => (->() do
        # Run a thread that sleeps i hours.
        #
        Thread.new do
          sleep i*3600
          James.controller.say "Hi, this is James, you set a reminder #{pluralized_hour(i)} ago, so I am reminding you! "*3
        end

        # Return affirmative message.
        #
        "Ok, I'll remind you in #{pluralized_hour(i)}."
      end)
    end
    into { "In how many hours should I remind you?" }
  end

end
