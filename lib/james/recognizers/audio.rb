module James

  module Recognizers

    class Audio < Base

      def initialize controller
        super controller
        @recognizer = NSSpeechRecognizer.alloc.init
        @recognizer.setBlocksOtherRecognizers true
        @recognizer.setListensInForegroundOnly false
        recognize_new_commands
        @recognizer.setDelegate self
      end

      def listen
        @recognizer.startListening
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
        @recognizer.setCommands controller.expects
      end

    end

  end

end