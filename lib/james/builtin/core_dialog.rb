# This is the core dialog every dialog will be hooking into.
#
# Eventually, the design should be such that everyone can use
# the design and core dialog they like best.
#
# But to get going, this suffices for now.
#
class CoreDialog

  include James::Dialog

  # This core dialog starts at away.
  #
  initially :away

  # The alert state.
  # When James is in this state, he should be
  # open for user dialogs.
  #
  state :awake do
    # If James is awake, he offers more dialogs
    # on this state, if there are any hooked into this state.
    #
    chainable

    hear "Thank you, James."              => :awake,
         "Go back."                       => :awake,
         'I need some time alone, James.' => :away,
         "Good night, James."             => :exit
    into { "Sir?" }
  end

  # The away state. James does not listen to any
  # user dialog hooks, but only for his name
  # or the good night, i.e. exit phrase.
  #
  state :away do
    hear 'James?'                => :awake,
         'Are you there, James?' => :awake,
         "Good night, James."    => :exit
    into { "Of course, Sir!" }
  end

  # This is not a real state. It just exists to Kernel.exit
  # James when he enters this state.
  #
  state :exit do
    into do
      puts "James exits through a side door."
      Kernel.exit
    end
  end

end