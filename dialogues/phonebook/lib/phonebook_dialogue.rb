# TODO remove
require File.dirname(__FILE__) + '/../../../dialogue_extension'
# require 'dialogue_extension'
require 'phonebook'

class PhonebookDialogue < DialogueExtension
  
  # this class again tells me that I absolutely need a mapping!!!
  NUMBER_MAPPING = {
    'nil' => 0,
    'one' => 1,
    'two' => 2,
    'three' => 3,
    'four' => 4,
    'five' => 5,
    'six' => 6,
    'seven' => 7,
    'eight' => 8,
    'nine' => 9,
    'ten' => [1,0],
    'eleven' => [1,1],
    'twelve' => [1,2],
    'thirteen' => [1,3],
    'fourteen' => [1,4],
    'ok' => :find,
    "that's it" => :find
  }
  CORRECT_MAPPING = {
    'erase' => 1,
    'erase 1' => 1,
    'erase 2' => 2,
    'erase 3' => 3,
    'erase all' => 20,
    'ok' => 0,
    'good' => 0
  }
  
  initial_state :phonebook
  hook_words 'Can you check the phonebook for me', 'phonebook'
  state :phonebook, {
    ['I need a name for the following number','I need a name','name',
     'I need an address for the following number','I need an address','address',
     'I need a name and address for the following number','I need a name and address','name and address'] => :number
  }
  state :number, {
    ['nil','one','two','three','four','five',
     'six','seven','eight','nine','ten',
     'eleven','twelve','thirteen','fourteen'] => :number,
    ['ok',"that's it"] => :result,
    'correct' => :correct
  }
  state :correct, {
    ['erase','erase 1','erase 2','erase 3','erase all'] => :correct,
    ['good','ok'] => :number
  }
  state :result, {
    'again' => :phonebook
  }
  
  def initialize
    @needs_name, @needs_address = false, false
    @number = []
    # reset
  end
  
  def exit_phonebook(heard)
    @name = heard =~ /name/
    @address = heard =~ /address/    
  end
  
  def enter_phonebook
    @number = []
    'What do you want me to find?'
  end
  
  def exit_correct(heard)
    # cut off numbers
    range_end = CORRECT_MAPPING[heard]
    puts "range_end: #{range_end}"
    puts "number: #{@number}"
    puts "neg. range end: #{-range_end}"
    @number = @number[0...-range_end]
    puts "number: #{@number}"
  end
  
  def enter_correct
    "the number is #{@number}."
  end
  
  def exit_number(heard)
    if NUMBER_MAPPING[heard] == :find
      return
    end
    @number << NUMBER_MAPPING[heard].to_s
    @number.flatten!
  end
  
  def enter_number # TODO (heard, mapping) ?
    if @number.empty?
      "The number, please."
    else
      @number[-1]
    end
  end
  
  def enter_result
    name, address = Phonebook.find(@number.to_s)
    result = ''
    result << "The name is #{name}. " if @name
    result << "The address is #{address}." if @address
    puts result
    result
  end

end