module James

  module Dialogue

    def self.included into
      into.extend ClassMethods
    end

    # We heard phrase.
    #
    def hear phrase
      @state = state.transition self, phrase
    end

    # next possible phrases
    # TODO splat
    def expects
      self.class.states.inject([]) do |total, state|
        total + state_for(state.first).hooks
      end
    end

    #
    #
    def state_for name
      self.class.state_for name
    end

    module ClassMethods

      # Defines the hooks into the main dialogue.
      #
      def hooks *sentences
        define_method :hooks do
          sentences
        end
        # self.class_eval do
        #   # set entry state correctly
        #   entry = {}
        #   hooks.each do |hook|
        #     entry[hook] = self.initial
        #   end
        #   # add states class variable
        #   class <<self
        #     attr_accessor :states
        #   end
        #   self.states ||= {}
        #   self.states[:entry] = entry
        #   # define an instance method
        #   define_method(:hooks) do
        #     hooks
        #   end
        # end
      end

      # Defines a state with transitions.
      #
      # state :name, { states }
      #
      attr_reader :states
      def state name, transitions = {}
        @states       ||= {}
        @states[name] ||= {}

        # Lazily create states.
        #
        @states[name] = transitions
      end
      def state_for name
        # Lazily wrap.
        #
        if @states[name].respond_to?(:each)
          @states[name] = State.new(name, @states[name])
        end

        @states[name]
      end

      # Defines the initial hook state.
      #
      def initial name
        define_method :state do
          @state ||= self.class.state_for name
        end
      end

    end

  end

end