module James

  # Registers dialogs and connects their states.
  #
  class Dialogs

    attr_reader :initial

    def initialize
      @initial = State.new :__initial_plugin_state__, nil
    end

    # Generate the graph for the dialogs.
    #
    # Hooks up the entry phrases of the dialog
    # into the main dialog.
    #
    # It raises if the hook phrase of a dialog
    # is already used.
    #
    def << dialog
      resolved_entries = {}

      dialog.entries.each do |(phrases, state)|
        resolved_entries[phrases] = state.respond_to?(:phrases) ? state : dialog.state_for(state)
      end

      # Hook the dialog into the initial state.
      #
      initial.hear resolved_entries
    end

    # Get the visitor.
    #
    # Initialized on the initial state.
    #
    def visitor
      @visitor ||= Visitor.new initial
    end

  end

end