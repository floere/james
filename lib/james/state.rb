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

    def next_for phrase
      self.transitions[phrase]
    end

    def to_s
      "#{self.class.name}(#{name}, #{transitions})"
    end

  end

end