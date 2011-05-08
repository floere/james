require File.expand_path '../visitor', __FILE__

module James

  # Registers all dialogues and connects their states.
  #
  class Dialogues

    attr_reader :dialogues

    def initialize
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
      # Hook into.
      #
      resolved_entries = {}
      dialogues.each do |dialogue|
        dialogue.entries.each do |(phrases, state)|
          resolved_entries[phrases] = state.respond_to?(:phrases) ? state : dialogue.state_for(state)
        end
      end

      @visitor = Visitor.new main.state :awake, resolved_entries
    end

    # Get a visitor on the initial state.
    #
    def visitor
      state = main.state_for :awake
      Visitor.new state
    end

  end

end