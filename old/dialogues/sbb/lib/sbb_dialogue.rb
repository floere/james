require 'dialog_extension'
require 'sbb'

# uses the sbb class to gather sbb information
# can be used in the dialog class as a delegate
class SbbDialog < DialogExtension

  HERE = 'bints'
  CITIES = ['berne','geneva','HB','basel','solothurn']
  CITIES_MAPPING = {
    'HB' => 'Zurich HB'
  }
  WEEKDAYS = ['monday','tuesday','wednesday','thursday','friday','saturday','sunday']
  # RELATIVE_TIMES = ['now','soon','tomorrow']
  RELATIVE_TIMES = { # in seconds from now
    'now' => 0,
    'soon' => 600,
    'tomorrow' => 24*3600
  }

  # TODO use city speech to model mapping

  initial_state :from
  hook_words 'sbb', 'train'
  state :from, {
    HERE => :to, # TODO add perhaps some kind of proc here?
    'need to run' => :result,
    CITIES => :to
  }
  state :to, {
    'back' => :from, # TODO factor out, make universal (like last state)
    ['next train','nowhere'] => :result,
    CITIES => :when
  }
  state :when, {
    'back' => :to,
    RELATIVE_TIMES.keys => :result
    # RELATIVE_TIMES | WEEKDAYS => :result
  }
  state :result, {
    # 'back' => :when,
    ['again','later','next','earlier'] => :result
  }
  
  def initialize
    @result_index = -10
    @from = ''
    @to = ''
    @when = Time.now
    # reset
    # puts self.moves.inspect
    # puts "#{self.class.name} === #{self.class.moves.inspect}"
  end
  
  def initial
    @@initial
  end
  
  # state changes
  
  def enter_from
    @result_index = -10
    'from?'
  end
  
  def exit_from(heard)
    puts "exit_from: #{heard}"
    if heard == HERE
      puts 'binz'
      @from = 'Binz SZU'
    elsif mapped_city = CITIES_MAPPING[heard]
      @from = mapped_city
    elsif heard == 'need to run'
      @from = 'Binz SZU'
      @to = 'Zurich HB'
      @when = Time.now + 10*60
    else
      @from = heard
    end
  end
  
  def enter_to
    'to?'
  end
  
  def exit_to(heard)
    # special cases
    if heard == 'next train'
      # get abfahrtstabelle
      @when = Time.now + 60*60
      @to = 'berne'
      return
    elsif mapped_city = CITIES_MAPPING[heard]
      @to = mapped_city
    else
      @to = heard
    end
  end
  
  def enter_when
    'when?'
  end
  
  def exit_when(phrase)
    # puts "phrase: #{phrase}"
    # TODO parse times
    case phrase
    when 'now'
      @when = Time.now
    when 'soon'
      @when = Time.now + 20*60 # 20 mins
    when 'tomorrow'
      @when = Time.now + 24*60*60 # 1 day
    end
  end
  
  def enter_result
    puts @result_index
    if 0 > @result_index or @result_index >= @result.size
      puts "searching #{@result_index}"
      @result = Sbb.find(@from, @to, @when)
      @result_index = 0
    end
    puts @result.inspect
    time = @result[@result_index][:departure].sub(/:/, ' ') if @result[@result_index]
    puts time.inspect
    if time
      "#{time}"
    else
      'SBB! not available at the time, sorry.'
    end
  end
  
  def exit_result(phrase)
    # todo move to procs
    if phrase == 'next'
      phrase = 'later'
    end
    case phrase
    when 'again'
      @result_index = -10
    when 'later'
      @result_index += 1
      puts @result_index
      if (@result_index >= @result.size) # @result[@result_index][:departure] != nil
        # TODO search from last
        # TODO results need to be time objects
        @when += @result.size*15*60
      end
    when 'earlier'
      @result_index -= 1
      if (@result_index < 0)
        @when -= 20*60
      end
    end
  end
  
  class ResultGetter
    
    def result(time)
      
    end
    
    def later!
      
    end
    
    def earlier!
      
    end
    
  end
  
end