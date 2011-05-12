# Note: This dialogue does not work yet due to a bug in MacRuby.
#
require 'twitter'

# If using the gem, replace with: require 'james'
#
require File.expand_path '../../lib/james', __FILE__

#
#
class TwitterDialogue

  include James::Dialogue

  # hear 'Give me the last melbourne university tweets please.' => :unimelb
  # state :unimelb do
  #   into do
  #     say = []
  #     @tweets ||= Twitter::Search.new
  #     @tweets.from('unimelb').result_type('mixed').no_retweets.per_page(3).each do |r|
  #       say << r.text.gsub(/\@\w+\s/, '')
  #     end
  #     say.join ' followed by '
  #   end
  # end

end