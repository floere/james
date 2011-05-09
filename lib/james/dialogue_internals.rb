require File.expand_path '../state_api', __FILE__
require File.expand_path '../state_internals', __FILE__
require File.expand_path '../dialogues', __FILE__

module James

  # A dialogue is just a container object
  # for defining states and executing methods.
  #
  module Dialogue

    def self.included into
      into.extend ClassMethods
      Dialogues << into
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
      def state name, &block
        @states       ||= {}
        @states[name] ||= block if block_given?
      end
      def state_for name, instance
        # Lazily wrap.
        #
        if states[name].respond_to?(:call)
          states[name] = State.new(name, instance, &states[name])
        end
        states[name]
      end

    end

  end

  # We don't care about the spelling.
  #
  Dialog = Dialogue

end