require 'dialog_extension'

class TimeDialog < DialogExtension
  
  initial_state :time
  hook_words "what's the time?"
  state :time, { 'again' => :time }
  
  def initialize
    # remove!
    # reset
  end
  
  def enter_time
    # TODO randomize
    prefixes = ["Exactly ", "It is ", "It's ", ""]
    index = rand(prefixes.size)
    time = Time.now
    hours = time.strftime("%H")
    minutes = time.strftime("%M")
    "#{prefixes[index]}#{hours} #{minutes}"
  end
  
  def exit_time(phrase)
    
  end
  
end