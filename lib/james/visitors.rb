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
  # TODO: Rename to Conversation.
  #
  class Visitors

    attr_reader :visitors

    # A Visitors keeps a stack of visitors.
    #
    def initialize initial
      @visitors = [initial]
    end

    # Hear tries all visitors in order
    # until one hears a phrase he knows.
    #
    # If a dialog boundary has been crossed:
    # A new visitor is added with the target
    # state of that heard phrase at the position.
    #
    # After that, all remaining visitors are
    # removed from the current stack (since
    # we are obviously not in one of the later
    # dialogs anymore).
    #
    def hear phrase, &block
      @visitors = visitors.inject([]) do |remaining, visitor|
        markers = visitor.hear phrase, &block
        remaining = remaining + markers
        break remaining if remaining.last.current?
        remaining
      end
    end

    # Enter enters the first visitor.
    #
    def enter
      visitors.first.enter
    end

    # Simply returns the sum of what phrases all dialogs do expect, front-to-back.
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