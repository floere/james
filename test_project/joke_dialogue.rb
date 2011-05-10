require File.expand_path '../../lib/james', __FILE__

# Little parody on the existing OSX joke
# telling system.
#
class JokeDialogue
  include James::Dialogue

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
    hear 'another one'
    into do
      jokes[rand(jokes.size)] + "... ... ... Ha ha ha."
    end
  end

end