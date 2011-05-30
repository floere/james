require File.expand_path '../../../lib/james', __FILE__

module James

  class CLI

    def execute *patterns
      options = extract_options patterns
      
      dialogs = find_dialogs_for patterns

      puts "James: I haven't found anything to talk about (No files found). Exiting." or exit!(1) if dialogs.empty?
      puts "James: Using dialogs in #{dialogs.join(', ')} for our conversation, Sir."

      load_all dialogs

      James.listen options
    end
    
    # Defines default options and extracts options from
    # command line.
    #
    # Sadly needs to be run before processing the dialog file names.
    #
    def extract_options patterns
      silent        = patterns.delete '-s'
      silent_input  = patterns.delete '-si'
      silent_output = patterns.delete '-so'
      
      options = {}
      options[:input]  = Inputs::Terminal  if silent || silent_input
      options[:output] = Outputs::Terminal if silent || silent_output
      
      options
    end
    
    #
    #
    def find_dialogs_for patterns
      patterns = ["**/*_dialog{,ue}.rb"] if patterns.empty?
      Dir[*patterns]
    end
    
    #
    #
    def load_all dialogs
      dialogs.each do |dialog|
        load File.expand_path dialog, Dir.pwd
      end
    end

  end

end