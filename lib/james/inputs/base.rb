module James

  module Inputs

    class Base

      attr_reader :controller

      def initialize controller
        @controller = controller
      end

      # Call this method if you heard something in the subclass.
      #
      def heard command
        # Call dialogue.
        #
        controller.hear command
      end

    end

  end

end