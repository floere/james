module James

  module Inputs

    class Base

      attr_reader :controller

      def initialize controller
        @controller = controller
      end

      def heard command
        # Call dialogue.
        #
        controller.hear command
      end

    end

  end

end