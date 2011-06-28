module James

  module Outputs

    class Audio

      # Create a new audio output.
      #
      # Options:
      #  * preferences # A James::Preferences
      #
      def initialize preferences
        @output = NSSpeechSynthesizer.alloc.initWithVoice preferences.voice
      end

      # Say the given text out loud.
      #
      # Waits for the last text to be finished
      #
      def say text
        while @output.isSpeaking
          sleep 0.1
        end
        @output.startSpeakingString text
      end

    end

  end

end