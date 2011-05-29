module James

  module Outputs

    # Terminal output for silent purposes.
    #
    class Terminal

      #
      #
      def initialize options = {}

      end

      # Say the given text in the terminal.
      #
      def say text
        puts
        p text
        puts
      end

    end

  end

end