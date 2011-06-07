module James

  module Markers

    # The visitor knows where in the conversation we are.
    #
    class Current < Marker

      attr_reader :initial

      # Hear a phrase.
      #
      # Returns a new marker if it crossed a boundary.
      # Returns itself if not.
      #
      def hear phrase, &block
        last = current
        process(phrase, &block) ? Memory.new(last) : self
      end

      # Expects all phrases, not just internal.
      #
      def expects
        current.expects
      end

    end

  end

end