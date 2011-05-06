require File.expand_path '../state', __FILE__

module James

  # A dialogue is just a container object
  # for defining states and executing methods.
  #
  module Dialogue

    def self.included into
      into.extend ClassMethods
      Dialogues << into
    end

    def self.define &block
      dialogue = Class.new do
        include James::Dialogue
      end
      dialogue.class_eval &block
      Dialogues << dialogue
    end

    #
    #
    def state_for name
      self.class.state_for name
    end

    module ClassMethods

      # Defines the entry sentences.
      #
      def entry definition
        define_method :entries do
          definition
        end
      end
      def exits *phrases

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
          @states[name] = State.new(name, self, @states[name])
        end

        @states[name]
      end

    end

  end

  # We don't care about the spelling.
  #
  Dialog = Dialogue

end