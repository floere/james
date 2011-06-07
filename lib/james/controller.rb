module James

  class Controller

    attr_reader :visitor, :listening

    # Singleton reader.
    #
    def self.instance
      @controller ||= new
    end

    # This puts together the initial dialog and the user
    # ones that are hooked into it.
    #
    # The initial dialog needs an state defined as initially.
    # This is where it will start.
    #
    # Example:
    #   initially :awake
    #   state :awake do
    #     # ...
    #   end
    #
    # If you don't give it an initial dialog,
    # James will simply use the built-in CoreDialog.
    #
    def initialize initial_dialog = nil
      @dialog  = initial_dialog || CoreDialog.new
      @visitor = Visitors.new @dialog.visitor
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

    # Convenience method to add a dialog to the current system.
    #
    # Will add the dialog to the initial dialog.
    #
    def add_dialog dialog
      @dialog << dialog
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