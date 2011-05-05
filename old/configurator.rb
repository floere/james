# TODO all

# configures
class Configurator
  def self.configure

  end
end

require 'osx/cocoa'

...

def initialize
  # get and configure a recognizer interface
  @recognizer = OSX::NSSpeechRecognizer.alloc.init
  @recognizer.setDelegate(self)
  @recognizer.startListening
  # get a synthesizer interface
  @synthesizer = OSX::NSSpeechSynthesizer.alloc.init
end

# callback method from the speech interface
def speechRecognizer_didRecognizeCommand( sender, command )
  # do something with the command
  # command needs to be converted to a proper ruby string: command.to_s
end

def speak(text)
  # say something using the speech synthesizer
  @synthesizer.startSpeakingString(text)
end

state :to, {
  'back' => :from,
  'next train' => :result,
  'nowhere' => :result
}.merge(CITIES)