require 'test/unit'
require '../../../test/test_helper'
require "quote_of_the_day"

class TestQuoteOfTheDay < Test::Unit::TestCase
  def test_quote_of_the_day
    QuoteOfTheDay.new.find
  end
end