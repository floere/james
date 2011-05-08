module James

  class State

    attr_reader :transitions

    # Returns all possible phrases that lead
    # away from this state.
    #
    def phrases
      transitions.keys
    end

    # Returns the next state for the given phrase.
    #
    # It accesses the context (Dialog(ue)) to get a full object state.
    #
    def next_for phrase
      state = self.transitions[phrase]
      state.respond_to?(:phrases) ? state : context.state_for(state)
    end

    def __into__
      @into_block && context.instance_eval(&@into_block)
    end
    def __exit__
      @exit_block && context.instance_eval(&@exit_block)
    end

  end

end