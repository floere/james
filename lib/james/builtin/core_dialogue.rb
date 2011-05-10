class CoreDialogue

  include James::Dialogue

  state :awake do
    chainable # If James is awake, he offers more dialogues on this state, if there are any.

    hear 'I need some time alone, James.'          => :away,
         "Good night, James."                      => :exit,
         ["Thank you, James.", "Thanks, James."]   => :awake
    into { "Sir?" }
  end

  state :away do
    hear 'James?'             => :awake,
         "Good night, James." => :exit
    into { "Of course, Sir!" }
  end

  state :exit do
    into do
      puts "James: Exits through a side door."
      Kernel.exit
    end
  end

end