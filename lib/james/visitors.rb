module James

  # The visitors class has a number of visitors, whose
  # dialogs are visited in order of preference.
  #
  # Why?
  # Discussions have multiple points where they can be.
  # (Politics, then this joke, then back again, finally "Oh, bye I have to go!")
  #
  # In James, though, it is much simpler.
  # We just have a visitor in an entry scenario
  # (James!, Sleep, Wake up, Something completely different)
  # and one in any specific user-given scenario.
  #
  # Visitors is a proxy object for visitors.
  #
  class Visitors

    attr_reader :visitors

    def initialize *visitors
      @visitors = visitors
    end

    def add_dialog dialog

    end

    # Hear tries all visitors in order
    # until one hears a phrase he knows.
    #
    # After that, all remaining visitors are reset.
    #
    def hear phrase, &block
      enumerator = visitors.dup

      while visitor = enumerator.shift
        visitor.hear phrase, &block and break
      end

      while visitor = enumerator.shift
        visitor.reset
      end
    end

    # Enter enters the first dialog.
    #
    def enter
      visitors.first.enter
    end

    # Simply returns the sum of what phrases all dialogs expect.
    #
    # Stops as soon as a visitor is not in a chainable state anymore.
    #
    def expects
      visitors.inject([]) do |expects, visitor|
        total = visitor.expects + expects
        break total unless visitor.chainable?
        total
      end
    end

  end

end