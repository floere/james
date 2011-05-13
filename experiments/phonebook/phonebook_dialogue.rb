# If using the gem, replace with: require 'james'
#
require File.expand_path '../../../lib/james', __FILE__

# Get the Phonebook model.
#
require File.expand_path '../phonebook', __FILE__

class PhonebookDialogue < DialogueExtension

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
    'fourteen' => [1,4]
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

  def initialize
    @needs_name, @needs_address = false, false
  end

  hear ['Can you check the phonebook for me', 'phonebook'] => :phonebook
  state :phonebook do
    hear ['I need a name for the following number','I need a name','name',
     'I need an address for the following number','I need an address','address',
     'I need a name and address for the following number','I need a name and address','name and address'] => :number
    into do
      @number = []
      'What do you want me to find?'
    end
    exit do |heard|
      @name = heard =~ /name/
      @address = heard =~ /address/
    end
  end
  state :number do
    hear ['nil','one','two','three','four','five',
          'six','seven','eight','nine','ten',
          'eleven','twelve','thirteen','fourteen'] => :number,
         ['ok',"that's it"] => :result,
         'correct' => :correct
    into do
      if @number.empty?
        "The number, please."
      else
        @number[-1] # Echo the last heard number.
      end
    end
    exit do |heard|
      return unless NUMBER_MAPPING[heard]
      @number << NUMBER_MAPPING[heard].to_s
      @number.flatten!
    end
  end
  state :correct do
    hear ['erase','erase 1','erase 2','erase 3','erase all'] => :correct,
         ['good','ok'] => :number
    into do
      "The number is #{@number}."
    end
    exit do |heard|
      # Cut off numbers.
      #
      range_end = CORRECT_MAPPING[heard]
      puts "range_end: #{range_end}"
      puts "number: #{@number}"
      puts "neg. range end: #{-range_end}"
      @number = @number[0...-range_end]
      puts "number: #{@number}"
    end
  end
  state :result do
    hear 'again' => :phonebook
    into do
      name, address = Phonebook.find(@number.to_s)
      result = ''
      result << "The name is #{name}. " if @name
      result << "The address is #{address}." if @address
      puts result
      result
    end
  end

end