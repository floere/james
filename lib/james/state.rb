module James

  class State

    attr_reader :name, :transitions

    def initialize name, transitions = []
      @name        = name
      @transitions = expand transitions
    end
    def expand transitions
      results = {}
      transitions.each do |phrases, state_name|
        [*phrases].each do |phrase|
          results[phrase] = state_name
        end
      end
      results
    end

    def hooks
      transitions.keys
    end

    def next_for phrase, dialogue
      dialogue.state_for self.transitions[phrase]
    end
    def exit dialogue, phrase
      dialogue.send :"exit_#{name}", phrase if dialogue.respond_to? :"exit_#{name}"
    end
    def enter dialogue
      dialogue.send :"enter_#{name}" if dialogue.respond_to? :"enter_#{name}"
    end
    def transition dialogue, phrase
      # Call exit method.
      #
      self.exit dialogue, phrase

      # TODO Say response?
      #
      state = next_for phrase, dialogue

      # Call entry method.
      #
      state.enter dialogue

      # Return the next state.
      #
      state
    end

    def to_s
      "#{self.class.name}(#{name}, #{transitions})"
    end

  end

end