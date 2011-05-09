require File.expand_path '../../../lib/james', __FILE__

module James

  class CLI

    def execute *given_dialogues
      dialogues = find_dialogues
      dialogues.select! { |dialogue| given_dialogues.any? { |given| dialogue =~ %r{#{given}_dialog(ue)?.rb$} } } unless given_dialogues.empty?

      puts "James: I haven't found anything to talk about (No *_dialog{ue,}.rb files found). Exiting." or exit!(1) if dialogues.empty?

      puts "James: Using #{dialogues.join(', ')} for our conversation, Sir."

      require_all dialogues

      James.listen
    end
    def find_dialogues
      Dir["**/*_dialog{,ue}.rb"]
    end
    def require_all dialogues
      dialogues.each do |dialogue|
        require File.expand_path dialogue, Dir.pwd
      end
    end

  end

end