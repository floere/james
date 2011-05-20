module James

  # A dialog is just a container object
  # for defining states and executing methods.
  #
  module Dialog

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
      # state :name do
      #   # state properties (hear, into, exit) go here.
      # end
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

end