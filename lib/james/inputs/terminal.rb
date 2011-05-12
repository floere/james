module James

  module Inputs

    # Terminal input for silent purposes.
    #
    class Terminal < Base

      def listen
        sleep 2
        loop do
          possibilities = controller.expects
          puts "Possibilities:\n  #{possibilities.join("\n  ")}"
          command = gets.chop
          puts "I heard '#{command}'."
          heard command if possibilities.include? command
        end
      end

    end

  end

end