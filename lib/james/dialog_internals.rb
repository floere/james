module James

  # A dialog is just a container object
  # for defining states and executing methods.
  #
  module Dialog

    def self.included into
      into.extend ClassMethods
    end

    # Returns a state instance for the given state / or state name.
    #
    # Note: Lazily creates the state instances.
    #
    def state_for possible_state
      return possible_state if possible_state.respond_to?(:phrases)
      self.class.state_for possible_state, self
    end

    # Chain (the states of) this dialog to the given state.
    #
    # Creates state instances if it is given names.
    #
    # Note: Be careful not to create circular
    #       state chaining. Except if you really
    #       want that.
    #
    def chain_to state
      warn "Define a hear => :some_state_name in a dialog to have it be able to chain to another." && return unless respond_to?(:entry_phrases)
      entry_phrases.each do |(phrases, entry_state)|
        state.hear phrases => state_for(entry_state)
      end
    end

    # Chain the given Dialog(s) to all chainable
    # states in this Dialog.
    #
    # Note: If you only want one state to chain,
    #       then get it from the otiginating dialog
    #       using dialog.state_for(:name) and
    #       append the dialog there:
    #       dialog.follows preceding_dialog.state_for(:name)
    #
    def << dialog_s
      self.class.states.each do |(name, definition)|
        state = state_for name # TODO Do not call this everywhere.
        dialog_s.chain_to(state) if state.chainable?
      end
    end

    module ClassMethods

      def initially state_name
        define_method :visitor do
          Visitor.new state_for(state_name)
        end
      end

      # Defines the entry phrases into this dialog.
      #
      # Example:
      #   hear 'Hello, James!' => :start
      #
      def hear definition
        define_method :entry_phrases do
          definition
        end
      end

      # Defines a state with transitions.
      #
      # Example:
      #   state :name do
      #     # state properties (hear, into, exit) go here.
      #   end
      #
      def state name, &block
        @states       ||= {}
        @states[name] ||= block if block_given?
      end

      #
      #
      attr_reader :states

      # Return a state for this name (and dialog instance).
      #
      def state_for name, instance
        # Lazily wrap in State instance.
        #
        if states[name].respond_to?(:call)
          states[name] = State.new(name, instance, &states[name])
        end
        states[name]
      end

    end

  end

end