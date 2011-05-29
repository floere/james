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
        controller.hear command
      end

      # Shows possible commands in the terminal.
      #
      def show_possibilities possibilities
        puts "Possibilities:\n"
        possibilities.each_with_index do |possibility, index|
          puts "#{index + 1})  #{possibility}"
        end
      end

    end

  end

end