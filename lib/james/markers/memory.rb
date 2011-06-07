module James

  module Markers

    # A marker is a point in conversation
    # where we once were and might go back.
    #
    # TODO: Rename to ?.
    #
    class Memory < Marker

        # Hear a phrase.
        #
        # Returns a new Current if it heard.
        # Returns itself if not.
        #
        def hear phrase, &block
          process(phrase, &block) ? Current.new(current) : self
        end

        # A marker does not care about phrases that cross dialog boundaries.
        #
        def expects
          current.internal
        end

      end

    end

end