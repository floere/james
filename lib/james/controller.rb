module James

  class Controller

    attr_reader :visitor, :listening

    def self.instance
      @controller ||= new
    end

    # This puts together the core dialog and the user
    # ones that are hooked into it.
    #
    # TODO Rewrite this. Design needs some refactoring.
    #
    def initialize
      @user_dialogs  = Dialogs.new
      system_visitor = Visitor.new CoreDialog.new.state_for(:awake)
      @visitor       = Visitors.new system_visitor, @user_dialogs.visitor
    end

    # MacRuby callback functions.
    #
    def applicationDidFinishLaunching notification
      start_output
      start_input
    end
    def windowWillClose notification
      exit
    end

    # Add a dialog to the current system.
    #
    def add_dialog dialog
      @user_dialogs << dialog
    end

    # Start recognizing words.
    #
    def start_input
      @input = @input_class.new self
      @input.listen
    end
    # Start speaking.
    #
    def start_output
      @output = @output_class.new @output_options
    end

    # Callback method from dialog.
    #
    def say text
      @output.say text
    end
    def hear text
      visitor.hear text do |response|
        say response
      end
    end
    def expects
      visitor.expects
    end

    # Start listening using the provided options.
    #
    # Options:
    #  * input  # Inputs::Terminal or Inputs::Audio (default).
    #  * output # Outputs::Terminal or Outputs::Audio (default).
    #
    def listen options = {}
      return if listening

      @input_class    = options[:input]  || Inputs::Audio
      @output_class   = options[:output] || Outputs::Audio

      @output_options ||= {}
      @output_options[:voice] = options[:voice] || 'com.apple.speech.synthesis.voice.Alex'

      app = NSApplication.sharedApplication
      app.delegate = self

      @listening = true

      app.run
    end

  end

end