class Bla

  include James::Dialogue

  hear 'James?' => :awake

  state :awake do
    hear 'Leave me alone, James' => :away
    into { "Sir?" }
  end

  state :away do
    hear 'Are you there, James?' => :awake,
         "That's it for today, James" => :exit
    into { "Goodbye, Sir" }
  end

  state :exit do
    into do
      puts "James: Exits through a side door."
      Kernel.exit
    end
  end

end