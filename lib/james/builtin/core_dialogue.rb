class CoreDialogue

  include James::Dialogue

  state :awake do
    chainable # If James is awake, he offers more dialogues on this state, if there are any.

    hear 'Leave me alone, James.'                  => :away,
         "That's it for today, James."             => :exit,
         "Something else, James."                  => :awake
    into { "Sir?" }
  end

  state :away do
    hear 'James?'                      => :awake,
         "That's it for today, James." => :exit
    into { "Of course, Sir!" }
  end

  state :exit do
    into do
      puts "James: Exits through a side door."
      Kernel.exit
    end
  end

end