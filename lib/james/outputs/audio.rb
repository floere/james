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
      def say text
        @output.startSpeakingString text
      end

    end

  end

end