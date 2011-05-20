# Note: This dialog does not work yet due to a bug in MacRuby.
#
require 'twitter'

# If using the gem, replace with:
#
# require 'rubygems'
# require 'james'
require File.expand_path '../../lib/james', __FILE__

# Twitter dialog by Florian Hanke.
#
# This is a bit more complex example providing a self.configure method.
#
class TwitterDialog

  include James::Dialog

  def initialize from
    @from = from
  end

  hear 'Give me the latest tweets please.' => :latest

  state :latest do
    hear 'Again please' => :latest
    into do
      say = []
      @tweets ||= Twitter::Search.new
      @tweets.from(@from).result_type('mixed').no_retweets.per_page(3).each do |r|
        say << r.text.gsub(/\@\w+\s/, '')
      end
      say.join ' followed by '
    end
  end

end

James.use TwitterDialog.new('hanke')
