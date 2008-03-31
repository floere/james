require 'rubygems'
require 'hpricot'
require 'open-uri'

class QuoteOfTheDay
  
  SOURCES = [
    "http://feeds.feedburner.com/brainyquote/QUOTEBR",
    "http://feeds.feedburner.com/brainyquote/QUOTEAR",
    "http://feeds.feedburner.com/brainyquote/QUOTEFU",
    "http://feeds.feedburner.com/brainyquote/QUOTELO",
    "http://feeds.feedburner.com/brainyquote/QUOTENA"
  ]
  
  def initialize
    @index = 0
    @quotes = []
  end
  
  def read
    @quotes[@index]
  end
  
  def find
    @quotes = []
    SOURCES.size.times { |i|
      # load source
      doc = Hpricot(open(SOURCES[i]))
      # get descriptions
      descriptions = (doc/"item>description")
      # get text without double quotes
      @quotes << descriptions.collect! { |d| d.inner_html.scan(/"(.*)"/) }.to_a
    }
    # puts @quotes.flatten.inspect
    @quotes.flatten!
  end
  
  def next
    @index += 1
    check_bounds
  end
  
  def last
    @index -= 1
    check_bounds
  end
  
  def check_bounds
    @index = @index.modulo(@quotes.size)
  end
  
  def random
    @index = rand(@quotes.size)
  end
  
end