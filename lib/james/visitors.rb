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

    def hear phrase, &block
      visitors.each do |visitor|
        visitor.hear phrase, &block and break
      end
    end

    def expects
      visitors.inject([]) { |expects, visitor| expects + visitor.expects }
    end

  end

end