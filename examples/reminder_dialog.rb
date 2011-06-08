# If using the gem, replace with:
#
# require 'rubygems'
# require 'james'
require File.expand_path '../../lib/james', __FILE__

# Simple reminder dialog by Florian Hanke.
#
James.dialog do

  hear 'Set a reminder' => :reminder

  state :reminder do
    10.downto(1).each do |i|
      hear "Remind me in #{i} hours" => (->() do
        # Run a thread that sleeps i hours.
        #
        Thread.new do
          sleep i
          James.controller.say "Hi, this is James, you set a reminder #{i} hours ago, so I am reminding you! "*3
        end

        # Return affirmative message.
        #
        "Ok, I'll remind you in #{i} hours."
      end)
    end
    into { "In how many hours should I remind you?" }
  end

end
