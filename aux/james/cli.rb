require File.expand_path '../../../lib/james', __FILE__

module James

  class CLI

    def execute *dialogues
      all_dialogues = Dir["*_dialog{,ue}.rb"]
      all_dialogues.each do |dialogue|
        next unless dialogues.empty? || dialogues.any? { |given_dialogue| dialogue =~ %r{#{given_dialogue}_dialog(ue)?.rb$} }
        require File.expand_path dialogue, Dir.pwd
      end

      Controller.run
    rescue StandardError => e
      p e
    end

  end

end