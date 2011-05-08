module James

  module Outputs

    class Audio


      def initialize voice = nil
        @output = NSSpeechSynthesizer.alloc.initWithVoice voice || 'com.apple.speech.synthesis.voice.Alex'
      end

      def say text
        @output.startSpeakingString text
      end

    end

  end

end