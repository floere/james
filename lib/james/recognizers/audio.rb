module James

  module Recognizers

    class Audio

      attr_reader :controller

      def initialize controller
        @controller = controller
        @recognizer = NSSpeechRecognizer.alloc.init

        @recognizer.setBlocksOtherRecognizers true
        @recognizer.setListensInForegroundOnly false

        recognize_new_commands

        @recognizer.setDelegate self
        @recognizer.startListening
      end

      # Callback method from the speech interface.
      #
      def speechRecognizer sender, didRecognizeCommand: command
        # Call dialogue.
        #
        controller.hear command

        # Set recognizable commands.
        #
        recognize_new_commands
      end
      def recognize_new_commands
        @recognizer.setCommands controller.expects
      end

    end

  end

end