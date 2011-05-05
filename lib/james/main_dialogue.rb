module James

  # This is the default main dialogue.
  #
  # It is a proxy to the internal dialogues.
  #
  class MainDialogue
    include Dialogue

    state :exit
    state :back, { 'quit dialogue' => :awake }
    state :awake, {
      'sleep' => :sleeping
    }
    state :sleeping, {
      'james' => :awake,
      'exit, please' => :exit
    }
    initial :awake

    # This variable defines if we are in a dialogue.
    #
    attr_reader :dialogue

    def initialize
      @dialogue = nil
    end

    # On entering awake state, listen to hooks. TODO Hooks dialogue?
    #
    def enter_awake
      @dialogue = nil
    end
    def enter_exit
      exit!
    end

  end

end