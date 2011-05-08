module James

  # This is the default main dialogue.
  #
  # It is a proxy to the internal dialogues.
  #
  class MainDialogue
    include Dialogue

    hear 'wake up james' => :awake

    # Create Protostate with block. Then, create instance instance_evaling block.
    #
    state :awake do
      hear 'sleep james' => :sleeping
      hear 'my options?' { |the_next| the_next.phrases.join ' ' }
      into { "At your service" }
      exit { "Right away" }
    end

    state :sleeping do
      hear 'wake up james' => :awake
      into { "Good night, Sir" }
    end

    # state :awake, {
    #   'sleep james' => :sleeping
    #   # 'james, my options?' => lambda { || } # stays in this state but executes.
    # }
    # state :sleeping, {
    #   'wake up james' => :awake
    # }
    # entry 'wake up james' => :awake
    #
    # def enter_sleeping
    #   "Good night, Sir"
    # end
    # def enter_awake
    #   "At your service"
    # end
    # def exit_awake
    #   "Right away"
    # end

  end

end