require File.expand_path '../../lib/james', __FILE__

# Little parody on the existing OSX joke
# telling system.
#
class JokeDialogue
  include James::Dialogue

  hooks 'tell me a funny thing', 'tell me a joke'
  state :joke, { 'another one' => :joke }
  initial :joke

  def initialize
    # remove!
    # reset
  end

  def enter_joke
    jokes = [
      # 'One night, George W. Bush is tossing restlessly in his White House bed. He awakens to see George Washington standing by him Bush asks him, "George, what''s the best thing I can do to help the country?"
      # "Set an honest and honorable example, just as I did," Washington advises, and then fades away...
      # The next night, Bush is astir again, and sees the ghost of Thomas Jefferson moving through the darkened bedroom. Bush calls out, "Tom, please! What is the best thing I can do to help the country?"
      # "Respect the Constitution, as I did," Jefferson advises, and dims from sight...
      # The third night sleep still does not come for Bush. He awakens to see the ghost of FDR hovering over his bed. Bush whispers, "Franklin, What is the best thing I can do to help the country?"
      # "Help the less fortunate, just as I did," FDR replies and fades into the mist...
      # Bush isn''t sleeping well the fourth night when he sees another figure moving in the shadows. It is the ghost of Abraham Lincoln. Bush pleads, "Abe, what is the best thing I can do right now to help the country?"
      # Lincoln replies, "Go see a play."',
      # 'Two doctors are in the hallway complaining about nurse Nancy.
      # "She\'s out of control!" the first doctor says. "She does everything backwards. Just last week I told her to give a man two milligrams of morphine every ten hours, she gave him 10 milligrams every two hours, he almost died!"
      # "That\'s nothing," said the second doctor, "earlier this week I told her to give a man an enema every 24 hours, she tried to give him 24 enemas in one hour!"
      # All of a sudden they heard a blood curldling scream from down the hallway.
      # "OH MY GOD! I just realized that I told nurse Nancy to prick Mr. Smiths boil!"',
      'What do you say to a cow that crosses in front of your car? ... ... Mooove over.',
      'What\'s green, has 6 legs, and if it falls out of a tree and lands on you, it could hurt? ... ... A pool table.',
      'What is the one thing everybody in the world is doing at the same time? ... ... Growing older.',
      'How many hamburgers can you eat on an empty stomach? ... ... Only one or part of one, because after that, your stomach is no longer empty.',
      'What\'s the difference between a jeweler and a jailor? ... ... One sells watches, and the other watches cells.',
      'What did the elephant say to the naked man? ... ... How do you breathe through that thing?'
    ]
    random_reply(jokes)
  end

end