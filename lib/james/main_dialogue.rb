module James

  # This is the default main dialogue.
  #
  # It is a proxy to the internal dialogues.
  #
  class MainDialogue
    include Dialogue

    state :exit
    state :awake, {
      'sleep' => :sleeping
    }
    state :sleeping, {
      'james' => :awake,
      'exit, please' => :exit
    }
    entry 'james' => :awake

    def enter_sleeping
      "Goodbye, sir"
    end
    def enter_awake
      "At your service"
    end
    def exit_awake
      "Of course"
    end
    def enter_exit
      System.exit
    end

  end

end