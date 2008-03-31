# require 'cocoa'

# TODO make   ['HB','berne','geneva'] => :from   possible using the splat operator
# add ability to chain dialogues a la   chain_dialogue :state, <dialogue_name>

# superclass for dialogue modules
# dialogues move along the moves
# if a state is entered, enter_#{state_name} is called
# if a state is exited, exit_#{state_name} is called
class DialogueExtension < Dialogue
  
  attr_reader :state
  
  alias :old_initialize :initialize
  
  # every subclass of this class automatically has its state set to :entry on creation
  # def initialize(*args)
  #   puts "Resetting ", self.name, "\n"
  #   reset
  #   old_initialize(*args)
  # end
  
  # # automatically adds a hook phrase
  # # meaning: adds a move from :awake to this hook word
  # # and also a method
  def initialize
    # reset
  end
  # 
  # # TODO improve this such that reset doesn't need to be called in each initializer!
  def reset
    @state = :entry
  end
  
  # TODO think about saying something after each method call though like this it is kept simple which is good
  def hear(phrase)
    # if next state
    return nil unless next_state(phrase)
    # call exit method
    send("exit_#{@state}".intern, phrase) if respond_to?("exit_#{@state}")
    # TODO say(response)
    # set actual state
    @state = self.next_state(phrase)
    # call entry method
    send("enter_#{@state}".intern) if respond_to?("enter_#{@state}")
  end
  
  # next possible phrases
  # TODO splat
  def expects
    self.class.moves[@state].keys
  end
  
  def next_state(phrase)
    self.class.moves[@state][phrase] if self.class.moves[@state]
  end
  
  # returns the possible states of this dialogue
  def self.possible_states
    self.moves.keys
  end
  
  # metaprog
  
  # hook words - these define when this dialogue is entered
  # adds a hooks method
  # TODO get hooks from yaml file
  def self.hook_words(*hooks)
    self.class_eval do
      # set entry state correctly
      entry = {}
      hooks.each do |hook|
        entry[hook] = self.initial
      end
      # add moves class variable
      class <<self
        attr_accessor :moves
      end
      self.moves ||= {}
      self.moves[:entry] = entry
      # define an instance method
      define_method(:hooks) do
        hooks
      end
    end
  end
  
  # initial state
  def self.initial_state(initial)
    self.class_eval do
      # add accessor for 
      class <<self
        attr_accessor :initial
      end
      self.initial = initial
    end
  end
  
  # state definitions like
  # state :name, { moves }
  def self.state(name, moves)
    self.class_eval do
      self.moves ||= {}
      self.moves[name] ||= {}
      # split arrays here instead of handling later specifically
      # can change the implementation later if needed
      moves.each do |words,state|
        words.each do |word|
          self.moves[name][word] = state
        end
      end
      #
      # self.moves[name] = moves
      # puts "moves for #{self.name} are #{self.moves.inspect}"
    end
    # puts "#{self.name} === #{self.moves.inspect}"
  end
  
end
