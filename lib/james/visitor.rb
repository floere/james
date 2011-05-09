require File.expand_path '../timer', __FILE__

module James

  # The visitor knows where in the conversation we are.
  #
  # It also remembers where it has to go back to if
  # too much time passes without input.
  #
  # Note: A visitor should generally be very stupid.
  # Note 2: We could call this Hearing, or Ear ;)
  #
  class Visitor

    attr_reader   :initial, :timer
    attr_accessor :current

    # Pass in an initial state to start from.
    #
    def initialize initial, timer = nil
      @current = initial

      @initial = initial
      # @timer   = timer || Timer.new
    end

    # Escapes the current state back to the initial.
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
      self.current = current.next_for phrase
    end
    def check
      escape && yield("That led nowhere.") unless current
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
    # Does the current state allow penetration into another dialogue?
    #
    def chainable?
      current.chainable?
    end

    def to_s
      "#{self.class.name}(#{initial}, current: #{current})"
    end

  end

end