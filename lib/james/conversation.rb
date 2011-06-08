module James

  # A conversation has a number of markers (position in dialog),
  # whose dialogs are visited in order of preference.
  #
  # Why?
  # Conversations have multiple points where they can be.
  # (Politics, then this joke, then back again, finally "Oh, bye I have to go!")
  #
  class Conversation

    attr_accessor :markers

    # A Conversation keeps a stack of markers with
    # an initial one.
    #
    def initialize initial
      @markers = [initial]
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
      self.markers = markers.inject([]) do |remaining, marker|
        markers = marker.hear phrase, &block
        remaining = remaining + markers
        break remaining if remaining.last && remaining.last.current?
        remaining
      end
    end

    # Enter enters the first visitor.
    #
    def enter
      markers.first.enter
    end

    # Simply returns the sum of what phrases all dialogs do expect, front-to-back.
    #
    # Stops as soon as a marker is not on a chainable state anymore.
    #
    def expects
      markers.inject([]) do |expects, marker|
        total = marker.expects + expects
        break total unless marker.chainable?
        total
      end
    end

  end

end