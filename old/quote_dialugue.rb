require 'quote_of_the_day'

class QuoteDialog
  include James::Dialog

  entry 'quote of the day', 'quote' => :quote
  state :quote, ['random', 'next', 'last', 'repeat'] => :quote

  def initialize
    @quoter = QuoteOfTheDay.new
    # reset
  end

  def find_quotes
    @last_search = Time.now
    puts 'finding quotes'
    @quoter.find
    @quoter.random
  end

  def exit_quote(phrase)
    case phrase
    when 'random'
      @quoter.random
    when 'next'
      @quoter.next
    when 'last'
      @quoter.last
    end
  end

  def enter_quote
    if @last_search.nil? or Time.now - @last_search > 600
      find_quotes
    end
    @quoter.read
  end

end