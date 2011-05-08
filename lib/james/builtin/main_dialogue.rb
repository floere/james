James.dialogue do

  hear 'James?' => :awake

  state :awake do
    hear 'Sleep, James, sleep' => :sleeping
    into { "Sir?" }
  end

  state :sleeping do
    hear 'James, are you there?' => :awake,
         'Exit, please'          => :exit
    into { "Goodbye, Sir" }
  end

  state :exit do
    into { Kernel.exit }
  end

end