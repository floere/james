# If using the gem, replace with:
#
# require 'rubygems'
# require 'james'
require File.expand_path '../../lib/james', __FILE__

# Time dialog by Florian Hanke.
#
# This is a very simple James example.
#
# It has only one state, :joke, and a single
# entry/hook phrase, "Tell me a joke"
#
# Improve the jokes ;)
#
James.use_dialog do

  hear 'Tell me a joke' => :joke

  state :joke do
    jokes = [
      'What do you say to a cow that crosses in front of your car? ... ... Mooove over.',
      'What\'s green, has 6 legs, and if it falls out of a tree and lands on you, it could hurt? ... ... A pool table.',
      'What is the one thing everybody in the world is doing at the same time? ... ... Growing older.',
      'How many hamburgers can you eat on an empty stomach? ... ... Only one or part of one, because after that, your stomach is no longer empty.',
      'What\'s the difference between a jeweler and a jailor? ... ... One sells watches, and the other watches cells.',
      'What did the elephant say to the naked man? ... ... How do you breathe through that thing?'
    ]
    hear 'Another one'
    into do
      "#{jokes[rand(jokes.size)]} ... ... ... Ha ha ha."
    end
  end

end

James.listen
