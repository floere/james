require 'osx/cocoa'
require 'dialogue'

require 'initializer'

# has exactly two states, sleeping and awake
# from the awake state, extensions can be plugged in to be delegated to them
class MainDialogue < Dialogue
  
  attr_accessor :state
  
  def initialize(frontend)
    load_names
    load_sentences
    @frontend = frontend
    @options = {
      :extension_timeout => 10,
      :sleep_timeout => 60
    }
    @extension_time = Time.now
    @awake_time = Time.now
    configure_extensions
    # actual state
    @state = :sleeping
    # moves
    @moves = {
      :sleeping => {
        @male_name => :awake,
        @female_name => :awake
      },
      :awake => {
        @sentences['sleep!'] => :sleeping,
        @sentences['return from dialogue!'] => :awake
      }
    }
  end
  
  # next possible phrases
  # TODO refactor
  # TODO categorize expects -> can display it differently in view
  def expects
    # phrases
    expected = @moves[@state].keys
    if @extension
      expected << @extension.expects
    else
      # not in an extension & awake
      if state == :awake
        @extensions.each do |extension|
          expected << extension.hooks
        end
      end
    end
    expected.flatten
  end
  
  # actual state of self or delegated
  def state
    if delegated?
      return @extension.state
    end
    @state
  end
  
  # returns nil or something
  def delegated?
    @extension
  end
  
  def next_state(phrase)
    state = next_overriding_state(phrase)
    return state if state
    state = next_delegated_state(phrase)
    return state if state
    nil
  end
  
  # overriding means more important
  def next_overriding_state(phrase)
    @moves[@state][phrase]
  end
  
  def next_delegated_state(phrase)
    if delegated?
      return @extension.next_state(phrase)
    end
    if hook?(phrase)
      # if it is a hook, we check this extension for the next state
      return hooked_extension(phrase).class.initial
    end
  end
  
  def hear(phrase)
    puts "hearing '#{phrase}'"
    
    # check for overriding phrases
    if next_overriding_state(phrase)
      # save old state
      old_state = @state
      # get next state
      @state = next_overriding_state(phrase)
      
      # call exit method
      #exit_response = send("exit_#{old_state}".intern, phrase) if @state
      send("exit_#{old_state}".intern, phrase) if old_state
      #say(exit_response) if exit_response.instance_of? String and !exit_response.empty?
      
      # exit extension
      exit_extension
      
      # send in between state message
      # overrides enter_<state>
      method_name = "from_#{old_state}_to_#{@state}"
      in_between = respond_to? method_name
      if in_between
        from_to_response = send(method_name.intern, phrase) 
        say(from_to_response) if from_to_response
        return
      end

      # call entry method
      if @state and not in_between
        enter_response = send("enter_#{@state}".intern)
        say(enter_response) if enter_response
        return
      end
    end
    
    # if not overriding, check if in extension
    if @extension || @extension = hooked_extension(phrase)
      # if the delegate can answer, we are happy
      delegate_response = delegate(phrase)
      if delegate_response
        say(delegate_response)
        return
      end
    end
    
    # if the phrase cannot be handled, say so and return to awake
    # this only occurs in badly formed dialogues
    say("I don't know what you mean.")
    exit_extension
  end
  
  # exit the current extension and return to true awake state
  def exit_extension
    @extension.reset if @extension
    @extension = nil
  end
  
  # TODO can be removed?
  def hook?(phrase)
    # check extensions for hooks
    @extensions.each do |extension|
      return true if extension.hooks.include?(phrase)
    end
    false
  end
  
  # gets the extension that includes the heard hook
  def hooked_extension(phrase)
    # check extensions
    @extensions.each do |extension|
      return extension if extension.hooks.include?(phrase)
    end
    nil
  end
  
  # delegate heard phrase to extension
  def delegate(heard_phrase)
    return @extension.send(:hear, heard_phrase)
  end
  
  # callback to frontend
  def say(text)
    puts "saying '#{text}'"
    # refactor
    @frontend.say(text)
  end
  
  # state methods
  
  def from_sleeping_to_awake(phrase)
    "#{phrase} here!"
  end
  
  def enter_sleeping
    exit_extension
    random_reply(@sentences['goes to sleep'])
  end
  
  def exit_sleeping(phrase)
    if phrase == @male_name
      @frontend.male
    elsif phrase == @female_name
      @frontend.female
    end
  end
  
  def enter_awake
    # randomize
    @awake_time = Time.now
    random_reply(@sentences['wakes up'])
  end
  
  def exit_awake(phrase)
    @extension_time = Time.now
  end
  
  private
  
  def configure_extensions
    # which dialogue extension it is in right now
    @extension = nil
    # actual packs
    @extensions = []  
    Dir['dialogues/**'].each do | dialogue_dir |
     dialogue_dir.match('(.*)(\/)(.*)')
     dialogue_file = $3 + '_dialogue'
     extend_with dialogue_file.camelize.constantize.new
    end
  end
  
  # extend the main dialogue
  # later added extension methods will not override old phrases
  def extend_with(extension)
    # reset extension
    extension.reset
    # append extension to list of extensions
    @extensions << extension
  end
  
  def load_names
    yaml_names = ''
    File.open(File.join(JAMES_ROOT, 'config/names.yml')) do |f| yaml_names << f.read end
    names = YAML.load(yaml_names)
    @male_name = names['male'] || 'james' # default
    @female_name = names['female'] || 'jamie' # default
  end
  
  def load_sentences
    yaml_sentences = ''
    File.open(File.join(JAMES_ROOT, 'config/sentences.yml')) do |f| yaml_sentences << f.read end
    @sentences = YAML.load(yaml_sentences)
  end
  
end
