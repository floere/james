module James

  module Markers

    # The visitor knows where in the conversation we are.
    #
    class Current < Marker

      # Hear a phrase.
      #
      # Returns a new marker and self if it crossed a boundary.
      # Returns itself if not.
      #
      def hear phrase, &block
        return [self] unless hears? phrase
        last = current
        process(phrase, &block) ? [Memory.new(last), self] : [self]
      end

      # Expects all phrases, not just internal.
      #
      def expects
        current.expects
      end

      def current?
        true
      end

    end

  end

end