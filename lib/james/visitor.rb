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
      @timer   = timer || Timer.new
    end

    # Escapes the current state back to the initial.
    #
    def escape
      timer.stop
      self.current = initial
    end

    # We hear a phrase.
    #
    # Also used to start the whole process.
    #
    def enter
      result = current.enter
      yield result if block_given?
      result
    end
    def exit phrase
      result = current.exit phrase
      yield result if block_given?
      result
    end
    def transition phrase
      self.current = current.next_for phrase
    end
    def check
      escape && yield("That led nowhere.") unless current
    end
    def hear phrase, &block
      timer.restart
      exit phrase, &block
      transition phrase
      check &block
      enter &block
    end
    def expects
      current.phrases
    end

  end

end