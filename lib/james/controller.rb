framework 'AppKit'

module James

  class Controller

    attr_reader :visitor

    # This puts together the core dialogue and the user
    # ones that are hooked into it.
    #
    def initialize
      user_visitor   = initialize_dialogues.visitor
      system_visitor = Visitor.new CoreDialogue.new.state_for(:awake)
      @visitor       = Visitors.new system_visitor, user_visitor
    end

    def applicationDidFinishLaunching notification
      load_voices
      start_output
      start_input
    end
    def windowWillClose notification
      exit
    end

    # Load voices from yaml.
    #
    def load_voices
      # TODO
    end

    # Initialize and "parse" the
    # dialogues.
    #
    def initialize_dialogues
      dialogues = Dialogues.new
      dialogues.resolve
      dialogues
    end
    # Start recognizing words.
    #
    def start_input
      @input = Inputs::Audio.new self
      @input.listen
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
      @visitor.expects
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

      app.run
    end
    # Simply put, if there is a controller, it is listening.
    #
    def listening?
      true
    end

  end

end