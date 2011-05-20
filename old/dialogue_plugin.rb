require 'rubycocoa'

# superclass for dialog modules
# dialogs move along the moves
# if a state is entered, enter_#{state_name} is called
# if a state is exited, exit_#{state_name} is called
class DialogPlugin
  
  # automatically adds a hook phrase
  # meaning: adds a move from :awake to this hook word
  # and also a method
  def initialize
    # actual state in this module
    @state = nil
    # defines possible moves from one state to another
    @moves = {
      
    }
  end
  
  # returns the possible states of this dialog
  def possible_states
    @moves.keys
  end
  
  # next possible phrases
  def expects_phrases
    @moves[@state].keys
  end
  
  def next_state(phrase)
    @moves[@state][phrase]
  end
  
  def hear(phrase)
    # if next state
    return unless next_state(phrase)
    # call exit method
    response = send("exit_#{@state}".intern, phrase)
    say response
    # set actual state
    @state = next_state(phrase)
    # call entry method
    response = send("enter_#{@state}")
    say response
  end
  
  def say(text)
    # TODO blah
  end
  
  # hook words - these define when this dialog is entered
  def hook_words(names = nil)
    names.each do |name|
       # TODO
    end
  end
  
  def initial_state(initial)
    define_method(:reset) do
      @state = initial
    end
  end
  
end
