module James

  module Outputs

    class Audio

      # Create a new audio output.
      #
      # Options:
      #  * voice # Default is 'com.apple.speech.synthesis.voice.Alex'.
      #
      def initialize options = {}
        @output = NSSpeechSynthesizer.alloc.initWithVoice options[:voice] || 'com.apple.speech.synthesis.voice.Alex'
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