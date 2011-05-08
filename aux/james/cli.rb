require File.expand_path '../../../lib/james', __FILE__

module James

  class CLI

    def execute *dialogues
      all_dialogues = Dir["**/*_dialog{,ue}.rb"]
      all_dialogues.select! { |dialogue| dialogues.any? { |given| dialogue =~ %r{#{given}_dialog(ue)?.rb$} } } unless dialogues.empty?

      puts "James: Using #{all_dialogues.join(', ')} for our conversation, Sir."

      all_dialogues.each do |dialogue|
        require File.expand_path dialogue, Dir.pwd
      end

      James.listen
    rescue StandardError => e
      p e
    end

  end

end