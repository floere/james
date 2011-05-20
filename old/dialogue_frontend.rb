require 'osx/cocoa'
require 'main_dialog'

# TODO move some stuff in the dialog
# TODO extract cocoa connection
# TODO implement callback

# debug
USE_TEXTUAL_INTERFACE = false

class DialogFrontend
  
  attr_reader :dialog

  def initialize
    # load voices
    load_voices
    
    # get a dialog
    @dialog = MainDialog.new(self)
    
    # get and configure a recognizer interface
    start_recognizer
    
    # get a synthesizer interface
    start_synthesizer

    # default voice
    male
  end
  
  # callback method from the speech interface
  def speechRecognizer_didRecognizeCommand( sender, command )
    command = command.to_s
    # call the dialog system
    @dialog.hear(command)
    # set actual commands
    self.commands = @dialog.expects
  end
  
  # callback method from dialog
  def say(text)
    @synthesizer.startSpeakingString(text)
  end
  
  # callback from dialog
  def male
    self.voice = @male_voice
  end
  
  # callback from dialog
  def female
    self.voice = @female_voice
  end
  
  # wrapper for the cocoa setCommands
  def commands=(commands)
    @recognizer.setCommands(commands)
    puts "expects: #{commands.join(', ')}"
  end
  
  private
  
  # specialized setter for voice
  def voice=(voice)
    @synthesizer.setVoice(voice)
  end

  # start recognizing words
  def start_recognizer
    @recognizer = OSX::NSSpeechRecognizer.alloc.init
    @recognizer.setBlocksOtherRecognizers(true)
    @recognizer.setListensInForegroundOnly(false)
    @recognizer.setDelegate(self)
    self.commands = @dialog.expects
    @recognizer.startListening
  end
  
  # start speaking
  def start_synthesizer
    @synthesizer = OSX::NSSpeechSynthesizer.alloc.init
  end
  
  # load voices from yaml
  def load_voices
    yaml_voices = ''
    File.open('config/voices.yml') do |f| yaml_voices << f.read end
    voices = YAML.load(yaml_voices)
    @male_voice = voices['male']
    @female_voice = voices['female']
  end

end

controller = DialogFrontend.new

# code to use a textual interface
while USE_TEXTUAL_INTERFACE
  exit_words = ['quit','exit']
  puts "'#{exit_words.join("' or '")}' to quit. Expects: #{controller.dialog.expects.join(', ')}"
  input = gets.chomp
  if exit_words.include?(input)
    break
  end
  controller.dialog.hear(input)
end

OSX::NSApplication.sharedApplication.run