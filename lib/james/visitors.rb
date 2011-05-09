module James

  # The visitors class has a number of visitors, whose
  # dialogues are visited in order of preference.
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

    # Hear tries all visitors in order
    # until one hears a phrase he knows.
    #
    # After that, all remaining visitors are reset.
    #
    def hear phrase, &block
      iterator = visitors.each

      while visitor = iterator.next
        visitor.hear phrase, &block and break
      end

      while visitor = iterator.next
        visitor.reset
      end
    rescue StopIteration
      # That's ok! Nothing to do here.
    end

    # Simply returns the sum of what phrases all dialogues expect.
    #
    def expects
      visitors.inject([]) { |expects, visitor| expects + visitor.expects }
    end

  end

end