require 'rubygems'
require 'yahoofinance'

# If using the gem, replace with:
#
# require 'rubygems'
# require 'james'
require File.expand_path '../../lib/james', __FILE__

# Stocks dialog by Florian Hanke.
#
# This is a very simple James example.
#
class StocksDialog

  include James::Dialog

  attr_reader :quotes, :stocks

  def initialize *stocks
    @quotes = YahooFinance::ExtendedQuote.new
    @stocks = stocks
  end

  hear 'How are my stocks?' => :stocks

  state :stocks do
    hear 'Again'
    into do
      say = []
      stocks.each do |stock|
        result = quotes.load_quote stock
        say << "#{stock} has moved #{result[28]}."
      end
      say.join ' '
    end
  end

end

James.use StocksDialog.new('AAPL')