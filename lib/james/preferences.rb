require 'yaml'

module James

  # This class loads the .james preferences
  # and handles them.
  #
  # The preferences are loaded once, at startup. To reload
  # the preferences, you have to restart James.
  #
  # It loads them in the following order of precedence:
  #  * .james
  #  * ~/.james
  #
  # If no dotfile is found, it will
  #
  class Preferences
    
    attr_reader :preferences
    
    def initialize
      load
    end
    
    # Preference accessors & defaults.
    #
    
    # Default is the OSX Alex voice.
    #
    def voice
      preferences['voice'] || 'com.apple.speech.synthesis.voice.Alex'
    end
    
    # Loads a set of preferences.
    #
    def load
      @preferences = load_from_file || {}
    end
    
    # Load the preferences from a file if
    # a suitable .james is found.
    #
    def load_from_file
      dotfile = find_file
      YAML.load_file dotfile if dotfile
    end

    # Finds dotfiles in order of precedence.
    #  * .james
    #  * ~/.james
    #
    # Returns nil if none is found.
    #
    def find_file
      Dir['.james', File.expand_path('~/.james')].first
    end

  end

end