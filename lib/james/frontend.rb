USE_TEXTUAL_INTERFACE = false

class DialogueFrontend

  attr_reader :dialogue

  def initialize
    # load voices
    load_voices

    # get a dialogue
    @dialogue = MainDialogue.new(self)

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
    # call the dialogue system
    @dialogue.hear(command)
    # set actual commands
    self.commands = @dialogue.expects
  end

  # callback method from dialogue
  def say(text)
    @synthesizer.startSpeakingString(text)
  end

  # callback from dialogue
  def male
    self.voice = @male_voice
  end

  # callback from dialogue
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
    self.commands = @dialogue.expects
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