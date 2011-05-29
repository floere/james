module James

  module Inputs

    # Terminal input for silent purposes.
    #
    class Terminal < Base

      # Start listening to commands by the user.
      #
      def listen
        sleep 2
        loop do
          possibilities = controller.expects
          show_possibilities possibilities
          command = get_command
          puts "I heard '#{command}'."
          command = possibilities[command.to_i-1] if Integer(command)
          heard command if possibilities.include? command
        end
      end

      # Get the next command by the user.
      #
      def get_command
        STDIN.gets.chop
      rescue IOError
        puts "Wait a second, please, Sir, I am busy."
        sleep 1
        retry
      end

    end

  end

end