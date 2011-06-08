module James

  module Markers

    # A marker is a point in conversation
    # where we once were and might go back.
    #
    # TODO: Rename to ?.
    #
    class Marker

        attr_accessor :current

        # Pass in an current state.
        #
        def initialize current
          @current = current
        end

        # Resets the current state back to the initial.
        #
        def reset
          # Never moves, thus never reset.
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

        #
        #
        def exit
          result = current.__exit__
          yield result if result && block_given?
          result
        end

        #
        #
        def transition phrase
          state_or_lambda = current.next_for phrase
          if state_or_lambda.respond_to?(:call)
            result = current.__transition__ &state_or_lambda # Don't transition.
            yield result if result && block_given?
            result
          else
            self.current = state_or_lambda
          end
        end

        #
        #
        def check
          yield("Whoops. That led nowhere. Perhaps you didn't define the target state?") unless self.current
        end

        # Returns falsy if it stays the same.
        #
        def process phrase, &block
          exit_text = exit &block
          last_context = current.context
          transition phrase, &block
          check &block
          into_text = enter &block
          last_context != current.context
        end

        #
        #
        def hears? phrase
          expects.include? phrase
        end

        # Does the current state allow penetration into another dialog?
        #
        def chainable?
          current.chainable?
        end

        def to_s
          "#{self.class.name}(#{initial}, current: #{current})"
        end

      end

    end

end