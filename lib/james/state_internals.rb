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

    # Conditionally send enter_... method to context.
    #
    def __into__
      @into_block && @into_block.call
    end
    # Conditionally send exit_... method to context.
    #
    def __exit__
      @exit_block && @exit_block.call
    end

  end

end