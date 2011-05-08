require File.expand_path '../state_api', __FILE__
require File.expand_path '../state_internals', __FILE__

module James

  # A dialogue is just a container object
  # for defining states and executing methods.
  #
  module Dialogue

    def self.included into
      into.extend ClassMethods
    end

    #
    #
    def state_for name
      self.class.state_for name, self
    end

    module ClassMethods

      # Defines the entry sentences.
      #
      def hear definition
        define_method :entries do
          definition
        end
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
      def state_for name, instance
        # Lazily wrap.
        #
        # TODO Rewrite!
        #
        if states[name].respond_to?(:each)
          states[name] = State.new(name, instance, states[name])
        end
        states[name]
      end

    end

  end

  # We don't care about the spelling.
  #
  Dialog = Dialogue

end