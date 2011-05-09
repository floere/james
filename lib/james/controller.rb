framework 'AppKit'

require File.expand_path '../inputs/base', __FILE__
require File.expand_path '../inputs/audio', __FILE__
require File.expand_path '../inputs/terminal', __FILE__

require File.expand_path '../outputs/audio', __FILE__
require File.expand_path '../outputs/terminal', __FILE__

require File.expand_path '../builtin/core_dialogue', __FILE__

module James

  class Controller

    attr_reader :visitor

    def initialize
      user_visitor   = initialize_dialogues.visitor
      system_visitor = Visitor.new CoreDialogue.new.state_for(:awake)
      @visitor       = Visitors.new system_visitor, user_visitor
    end

    def applicationDidFinishLaunching notification
      load_voices

      start_output
      start_input

      visitor.enter { |text| say text }

      @input.listen
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

    def initialize_dialogues
      # Create the main dialogue.
      #
      # Everybody hooks into this, then.
      #
      dialogues = Dialogues.new
      dialogues.resolve
      dialogues
    end
    # Start recognizing words.
    #
    def start_input
      @input = Inputs::Audio.new self
    end
    # Start speaking.
    #
    def start_output
      @output = Outputs::Audio.new
    end

    # Callback method from dialogue.
    #
    def say text
      @output.say text
    end
    def hear text
      @visitor.hear text do |response|
        say response
      end
    end
    def expects
      possibilities = @visitor.expects
      puts "Possibilities:\n  #{possibilities.join("\n  ")}"
      possibilities
    end

    def listen
      app = NSApplication.sharedApplication
      app.delegate = self

      # window = NSWindow.alloc.initWithContentRect([100, 300, 300, 100],
      #     styleMask:NSTitledWindowMask|NSClosableWindowMask|NSMiniaturizableWindowMask,
      #     backing:NSBackingStoreBuffered,
      #     defer:false)
      # window.title      = 'James Debug/Info'
      # window.level      = 3
      # window.delegate   = app.delegate

      # @button = NSButton.alloc.initWithFrame([10, 10, 400, 10])
      # @button.bezelStyle = 4
      # @button.title      = ''
      # @button.target     = app.delegate
      # @button.action     = 'say_hello:'
      #
      # window.contentView.addSubview(@button)

      # window.display
      # window.orderFrontRegardless

      app.delegate.applicationDidFinishLaunching nil

      app.run
    end
    # Simply put, if there is a controller, it is listening.
    #
    def listening?
      true
    end

  end

end