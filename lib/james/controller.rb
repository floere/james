framework 'AppKit' # if respond_to?(:framework)

module James

  class Controller

    attr_reader :dialogue

    def applicationDidFinishLaunching notification
      load_voices
      initialize_dialogue
      start_output
      start_input

      self.voice = 'com.apple.speech.synthesis.voice.Alex'
    end
    def windowWillClose notification
      puts "James is going to bed."
      exit
    end

    # Load voices from yaml.
    #
    def load_voices
      # yaml_voices = ''
      # File.open('voices.yml') do |f| yaml_voices << f.read end
      # voices = YAML.load(yaml_voices)
      # @male_voice = voices['male']
      # @female_voice = voices['female']
      # Commented voices are Apple built-in voices. Can be changed by replacing the last part e.g.'Vicki' with e.g.'Laura'
      # much better female voice from iVox:
      # female: com.acapela.iVox.voice.iVoxHeather22k
      # much better male voice from iVox:
      # male: com.acapela.iVox.voice.iVoxRyan22k
      # female: com.apple.speech.synthesis.voice.Vicki
      # male: com.apple.speech.synthesis.voice.Bruce
    end
    def voice= name
      @synthesizer.setVoice name
    end

    def initialize_dialogue
      @dialogue = MainDialogue.new
    end
    # Start recognizing words.
    #
    def start_input
      @input = Recognizers::Audio.new self
    end
    # Start speaking.
    #
    def start_output
      @synthesizer = NSSpeechSynthesizer.alloc.init
    end

    # Callback method from dialogue.
    #
    def say text
      @synthesizer.startSpeakingString text
    end
    def hear text
      @dialogue.hear text
    end
    def expects
      @dialogue.expects
    end

  end

end

app = NSApplication.sharedApplication
app.delegate = James::Controller.new

# window = NSWindow.alloc.initWithContentRect([200, 300, 300, 100],
#     styleMask:NSTitledWindowMask|NSClosableWindowMask|NSMiniaturizableWindowMask,
#     backing:NSBackingStoreBuffered,
#     defer:false)
# window.title      = 'MacRuby: The Definitive Guide'
# window.level      = 3
# window.delegate   = app.delegate
#
# button = NSButton.alloc.initWithFrame([80, 10, 120, 80])
# button.bezelStyle = 4
# button.title      = 'Hello World!'
# button.target     = app.delegate
# button.action     = 'say_hello:'
#
# window.contentView.addSubview(button)
#
# window.display
# window.orderFrontRegardless

app.delegate.applicationDidFinishLaunching nil

app.run