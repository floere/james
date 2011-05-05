require 'test/unit'
require '../../../test/test_helper'
require '../../../test/dummy_frontend'
require 'sbb'
require 'main_dialogue'
require 'sbb_dialogue'

class TestSbb < Test::Unit::TestCase
  
  attr_reader :dialogue
  
  def setup
    @dialogue = MainDialogue.new(DummyFrontend.new)
  end
  
  # not really an automated test - still need human visual processing
  def test_sbb
    puts Sbb.find('geneva', 'berne', Time.utc(2007,"feb",8,13,0,0)).inspect
  end
  
  # TODO fix
  def test_sbb_next_train
    dialogue.extend_with(SbbDialogue.new)
    dialogue.hear('james')
    
    assert_equal(:awake, dialogue.state)
    assert_equal(:from, dialogue.next_state('train'))
    dialogue.hear('train')
    assert_equal(:from, dialogue.state)
    dialogue.hear('basel')
    assert_equal(:to, dialogue.state)
    assert_equal(:result, dialogue.next_state('next train'))
    dialogue.hear('next train')
    assert_equal(:result, dialogue.state)
    dialogue.hear('go back')
    assert_equal(:awake, dialogue.state)
    dialogue.hear('sleep')
    assert_equal(:sleeping, dialogue.state)
  end
end