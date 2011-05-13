# Note: This dialogue does not work yet due to a bug in MacRuby.
#
require 'twitter'

# If using the gem, replace with: require 'james'
#
require File.expand_path '../../lib/james', __FILE__

# Twitter dialogue by Florian Hanke.
#
# This is a bit more complex example providing a self.configure method.
#
class TwitterDialogue

  include James::Dialogue

  def self.configure from

    hear 'Give me the latest tweets please.' => :latest
    state :latest do
      hear 'Again please' => :latest
      into do
        say = []
        @tweets ||= Twitter::Search.new
        @tweets.from(from).result_type('mixed').no_retweets.per_page(3).each do |r|
          say << r.text.gsub(/\@\w+\s/, '')
        end
        say.join ' followed by '
      end
    end

  end

end

# This could be somewhere else of course.
#
TwitterDialogue.configure 'hanke'

James.listen