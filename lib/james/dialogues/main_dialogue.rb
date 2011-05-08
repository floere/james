James.dialogue do

  hear 'James?' => :awake

  state :awake do
    into { "Yes, Sir?" }
    hear 'Sleep, James' => :sleeping
    exit { "Right away, Sir" }
  end

  state :sleeping do
    hear 'James?' => :awake, 'Exit, please' => :exit
    into { "Good bye, Sir" }
  end

  state :exit do
    into { Kernel.exit }
  end

end