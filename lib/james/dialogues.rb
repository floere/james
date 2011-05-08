require File.expand_path '../visitor', __FILE__

module James

  # Registers all dialogues and connects their states.
  #
  class Dialogues

    attr_reader :initial, :dialogues

    def initialize
      @initial   = State.new :__initial_plugin_state__, nil
      @dialogues = self.class.dialogues.map &:new
    end

    class << self

      attr_reader :dialogues

      def << dialogue
        @dialogues ||= []
        @dialogues << dialogue
      end

    end

    # Generate the graph for the dialogues.
    #
    # Hooks up the entry phrases of all dialogues
    # into the main dialogue.
    #
    # It raises if the hook phrase of a dialogue
    # is already used.
    #
    def resolve
      # Hook dialogues into initial state.
      #
      resolved_entries = {}
      dialogues.each do |dialogue|
        dialogue.entries.each do |(phrases, state)|
          resolved_entries[phrases] = state.respond_to?(:phrases) ? state : dialogue.state_for(state)
        end
      end

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