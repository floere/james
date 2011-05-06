module James

  class State

    attr_reader :name, :context, :transitions

    # A state has a name
    #
    def initialize name, context, api_transitions = {}
      @name        = name
      @context     = context
      @transitions = expand api_transitions
    end
    # Expands a hash in the form
    #  * [a, b] => c to a => c, b => c
    # but leaves a non-array key alone.
    #
    def expand transitions
      results = {}
      transitions.each_pair do |phrases, state_name|
        [*phrases].each do |phrase|
          results[phrase] = state_name
        end
      end
      results
    end

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
    def enter
      method_name = :"enter_#{name}"
      if context.respond_to? method_name
        args = [method_name, self]
        context.send *args.shift(context.method(method_name).arity + 1)
      end
    end
    # Conditionally send exit_... method to context.
    #
    def exit
      context.send :"exit_#{name}" if context.respond_to? :"exit_#{name}"
    end

    def to_s
      "#{self.class.name}(#{name}, #{context}, #{transitions})"
    end

  end

end