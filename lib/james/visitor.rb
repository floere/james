module James

  # The visitor knows where in the conversation we are.
  #
  # It also remembers where it has to go back to if
  # too much time passes without input.
  #
  # Note: A visitor should generally be very stupid.
  #
  class Visitor

    attr_reader   :initial, :timer
    attr_accessor :current

    # Pass in an initial state to start from.
    #
    def initialize initial
      @current = initial

      @initial = initial
      # @timer   = Timer.new self
    end

    # Resets the current state back to the initial.
    #
    def reset
      # timer.stop
      self.current = initial
    end

    # We hear a phrase.
    #
    # Also used to start the whole process.
    #
    def enter
      result = current.__into__
      yield result if result && block_given?
      result
    end
    def exit
      result = current.__exit__
      yield result if result && block_given?
      result
    end
    def transition phrase
      state_or_lambda = current.next_for phrase
      if state_or_lambda.respond_to?(:call)
        current.__transition__ &state_or_lambda # Don't transition.
      else
        self.current = state_or_lambda
      end
    end
    def check
      reset && yield("Whoops. That led nowhere. Perhaps you didn't define the target state?") unless self.current
    end
    def hear phrase, &block
      return unless hears? phrase
      # timer.restart
      exit_text = exit &block
      transition phrase
      check &block
      into_text = enter &block
      exit_text || into_text
    end
    def hears? phrase
      expects.include? phrase
    end
    def expects
      current.phrases
    end
    # Does the current state allow penetration into another dialog?
    #
    def chainable?
      current.chainable?
    end

    def to_s
      "#{self.class.name}(#{initial}, current: #{current})"
    end

  end

end