require 'test/unit'
require '../../../test/test_helper'
require 'rubygems'
require 'phonebook'
# TODO remove
require File.dirname(__FILE__) + '/../../../dialogue_extension'
require 'phonebook_dialogue'

class TestPhonebook < Test::Unit::TestCase
  # not really an automated test - still need human visual processing
  # def test_phonebook
  #   puts Phonebook.find('0443643532').inspect
  # end
  
  def test_phonebook_dialogue
    dialogue = PhonebookDialogue.new
    
    assert_equal(:entry, dialogue.state)
    assert_equal(:phonebook, dialogue.next_state('phonebook'))
    dialogue.hear('phonebook')
    assert_equal(:phonebook, dialogue.state)
    assert_equal(:number, dialogue.next_state('name and address'))
    dialogue.hear('name and address')
    
    assert_equal(:number, dialogue.next_state('zero'))
    dialogue.hear('zero')
    assert_equal(:number, dialogue.next_state('four'))
    dialogue.hear('four')    
    assert_equal(:number, dialogue.next_state('four'))
    dialogue.hear('four')
    
    assert_equal(:number, dialogue.next_state('three'))
    dialogue.hear('three')
    assert_equal(:number, dialogue.next_state('six'))
    dialogue.hear('six')
    assert_equal(:number, dialogue.next_state('four'))
    dialogue.hear('four')
    
    assert_equal(:number, dialogue.next_state('three'))
    dialogue.hear('three')
    assert_equal(:number, dialogue.next_state('five'))
    dialogue.hear('five')
    
    assert_equal(:number, dialogue.next_state('three'))
    dialogue.hear('three')
    assert_equal(:number, dialogue.next_state('two'))
    dialogue.hear('two')
    
    assert_equal(:result, dialogue.next_state("that's it"))
    dialogue.hear("that's it")
    
  end
end