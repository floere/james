# If using the gem, replace with:
#
# require 'rubygems'
# require 'james'
require File.expand_path '../../../lib/james', __FILE__

# This is an example of a complex multilevel dialog not using the API.
#

# It is structured like this:
#
# Initially in Here ("talking to you")
# Away <-> Here -> C <-> D -> E <-> F
#               -> E <-> F
#
# States which are chainable – like B, or D – can have dialogs attached to them.
# The chainable states' phrases are always available.
#
# So if you came to F through B and D, you will always be able
# to go to Away directly (from B), and to C, from D.
#
# What, why? (You might ask)
# I suggest that conversations work a little this way.
# People talk about A, leading them to B, then C.
# At some point, people might want to go back or exit
# the conversation, bringing them back to A.
# (A could be Hello/Bye, with states :here, :away, and
# :away -> "hello" -> :here, :here -> "bye" -> :away,
# and :here being chainable, thus able to append dialogs
# to it)
#
# So if you attached two dialogs to our simple hi/bye...
# This is what it'd look like.
#

class Initial

  include James::Dialog

  initially :here

  state :away do
    hear 'Stay away'
    hear 'Come here' => :here
    hear ['Exit', 'Bye bye'] => :exit
    into do
      "Bye."
    end
  end
  state :here do
    chainable # Starting point for other dialogs.

    hear 'Stay here'
    hear 'Go away' => :away
    into do
      "Hi there. From here you can continue to C and E, or I can go away."
    end
  end
  state :exit do
    into { puts "Bye bye!"; exit! }
  end

end

class ComplexCD

  include James::Dialog

  hear 'Go to C' => :c

  state :c do
    hear 'Go to D' => :d
    into do
      "Welcome to C. From here you can continue on to D, or go back to A."
    end
  end
  state :d do
    chainable

    hear 'Stay in D'
    hear 'Go to C' => :c
    into do
      "Welcome to D. From here you can continue to E, or back to C, or even A."
    end
  end

end

class ComplexEF

  include James::Dialog

  hear 'Go to E' => :e

  state :e do
    hear 'Go to F' => :f
    into do
      "Welcome to E. From here you can continue on to F, or go back to C, or even A."
    end
  end
  state :f do
    chainable

    hear 'Stay in F'
    hear 'Go to E' => :e
    into do
      "Welcome to F. From here you can go back to "
    end
  end

end

# Create the dialogs.
#
initial = Initial.new
cd      = ComplexCD.new
ef      = ComplexEF.new

# Attach them to chainable states (an an explicit one, just as an example)
#
initial << cd
initial.here << ef
cd << ef

# Create a controller which listens/speaks to the terminal.
#
controller = James::Controller.new initial
controller.listen input:  James::Inputs::Terminal,
                  output: James::Outputs::Terminal