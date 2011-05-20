require 'test_helper'
require '../main_dialog'
require 'dummy_frontend'
require 'yaml'

# TODO require all files inside the extensions subdirectory
Dir['dialogs/**/lib/**_dialog.rb'].each do | dialog_file |
  dialog_file.to_s.match(/(.*)(\.)/)
  require $1
end

class TestDialog < Test::Unit::TestCase
  
  attr_reader :dialog
  
  def setup
    @dialog = MainDialog.new(DummyFrontend.new)
  end
  
  def test_dummy_frontend
    dummy = DummyFrontend.new
    methods = [:say, :male, :female]
    methods.each do |name|
      assert(dummy.respond_to?(:say), "Frontends need to implement method " + name.to_s)
    end
  end
  
  def test_sleeping_awake
    assert_equal(:sleeping, dialog.state)
    assert_equal(:awake, dialog.next_state('james'))
    dialog.hear('james')
    assert_equal(:awake, dialog.state) 
  end
  
  def test_awake_sleeping
    dialog.hear('james')
    assert_equal(:awake, dialog.state)

    assert_equal(:sleeping, dialog.next_state('sleep'))
    
    dialog.hear('sleep')
    assert_equal(:sleeping, dialog.state)
    dialog.hear('james')
    assert_equal(:awake, dialog.state)
  end
  
  # the following test is dependent on the config file's content
  def test_expects_phrases
    assert_equal(['jamie','james'], dialog.expects)
    dialog.hear('james')
    dialog.hear('sleep')
    assert_equal(['jamie','james'], dialog.expects)
    dialog.hear('jamie')
    dialog.hear('sleep')
    assert_equal(['jamie','james'], dialog.expects)
  end
  
end