require 'test_helper'
require '../main_dialogue'
require 'dummy_frontend'
require 'yaml'

# TODO require all files inside the extensions subdirectory
Dir['dialogues/**/lib/**_dialogue.rb'].each do | dialogue_file |
  dialogue_file.to_s.match(/(.*)(\.)/)
  require $1
end

class TestDialogue < Test::Unit::TestCase
  
  attr_reader :dialogue
  
  def setup
    @dialogue = MainDialogue.new(DummyFrontend.new)
  end
  
  def test_dummy_frontend
    dummy = DummyFrontend.new
    methods = [:say, :male, :female]
    methods.each do |name|
      assert(dummy.respond_to?(:say), "Frontends need to implement method " + name.to_s)
    end
  end
  
  def test_sleeping_awake
    assert_equal(:sleeping, dialogue.state)
    assert_equal(:awake, dialogue.next_state('james'))
    dialogue.hear('james')
    assert_equal(:awake, dialogue.state) 
  end
  
  def test_awake_sleeping
    dialogue.hear('james')
    assert_equal(:awake, dialogue.state)

    assert_equal(:sleeping, dialogue.next_state('sleep'))
    
    dialogue.hear('sleep')
    assert_equal(:sleeping, dialogue.state)
    dialogue.hear('james')
    assert_equal(:awake, dialogue.state)
  end
  
  # the following test is dependent on the config file's content
  def test_expects_phrases
    assert_equal(['jamie','james'], dialogue.expects)
    dialogue.hear('james')
    dialogue.hear('sleep')
    assert_equal(['jamie','james'], dialogue.expects)
    dialogue.hear('jamie')
    dialogue.hear('sleep')
    assert_equal(['jamie','james'], dialogue.expects)
  end
  
end