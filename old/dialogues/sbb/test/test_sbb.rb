require 'test/unit'
require '../../../test/test_helper'
require '../../../test/dummy_frontend'
require 'sbb'
require 'main_dialog'
require 'sbb_dialog'

class TestSbb < Test::Unit::TestCase
  
  attr_reader :dialog
  
  def setup
    @dialog = MainDialog.new(DummyFrontend.new)
  end
  
  # not really an automated test - still need human visual processing
  def test_sbb
    puts Sbb.find('geneva', 'berne', Time.utc(2007,"feb",8,13,0,0)).inspect
  end
  
  # TODO fix
  def test_sbb_next_train
    dialog.extend_with(SbbDialog.new)
    dialog.hear('james')
    
    assert_equal(:awake, dialog.state)
    assert_equal(:from, dialog.next_state('train'))
    dialog.hear('train')
    assert_equal(:from, dialog.state)
    dialog.hear('basel')
    assert_equal(:to, dialog.state)
    assert_equal(:result, dialog.next_state('next train'))
    dialog.hear('next train')
    assert_equal(:result, dialog.state)
    dialog.hear('go back')
    assert_equal(:awake, dialog.state)
    dialog.hear('sleep')
    assert_equal(:sleeping, dialog.state)
  end
end