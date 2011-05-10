module James

  module Inputs

    class Audio < Base

      def initialize controller
        super controller
        @recognizer = NSSpeechRecognizer.alloc.init
        @recognizer.setBlocksOtherRecognizers true
        @recognizer.setListensInForegroundOnly false
        @recognizer.setDelegate self
      end

      def listen
        @recognizer.startListening
        recognize_new_commands
      end
      def heard command
        super

        # Set recognizable commands.
        #
        recognize_new_commands
      end

      # Callback method from the speech interface.
      #
      def speechRecognizer sender, didRecognizeCommand: command
        heard command
      end
      def recognize_new_commands
        possibilities = controller.expects
        puts "Possibilities:\n  #{possibilities.join("\n  ")}"
        @recognizer.setCommands possibilities
      end

    end

  end

end