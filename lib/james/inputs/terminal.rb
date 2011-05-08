module James

  module Inputs

    class Terminal < Base

      def listen
        loop do
          puts %Q{What would you like? Possibilities include\n"#{controller.expects.join('", "')}"}
          command = gets.chop
          puts "I heard '#{command}'."
          heard command if controller.expects.include? command
        end
      end

    end

  end

end