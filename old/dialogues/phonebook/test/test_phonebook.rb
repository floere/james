require 'test/unit'
require '../../../test/test_helper'
require 'rubygems'
require 'phonebook'
# TODO remove
require File.dirname(__FILE__) + '/../../../dialog_extension'
require 'phonebook_dialog'

class TestPhonebook < Test::Unit::TestCase
  # not really an automated test - still need human visual processing
  # def test_phonebook
  #   puts Phonebook.find('0443643532').inspect
  # end
  
  def test_phonebook_dialog
    dialog = PhonebookDialog.new
    
    assert_equal(:entry, dialog.state)
    assert_equal(:phonebook, dialog.next_state('phonebook'))
    dialog.hear('phonebook')
    assert_equal(:phonebook, dialog.state)
    assert_equal(:number, dialog.next_state('name and address'))
    dialog.hear('name and address')
    
    assert_equal(:number, dialog.next_state('zero'))
    dialog.hear('zero')
    assert_equal(:number, dialog.next_state('four'))
    dialog.hear('four')    
    assert_equal(:number, dialog.next_state('four'))
    dialog.hear('four')
    
    assert_equal(:number, dialog.next_state('three'))
    dialog.hear('three')
    assert_equal(:number, dialog.next_state('six'))
    dialog.hear('six')
    assert_equal(:number, dialog.next_state('four'))
    dialog.hear('four')
    
    assert_equal(:number, dialog.next_state('three'))
    dialog.hear('three')
    assert_equal(:number, dialog.next_state('five'))
    dialog.hear('five')
    
    assert_equal(:number, dialog.next_state('three'))
    dialog.hear('three')
    assert_equal(:number, dialog.next_state('two'))
    dialog.hear('two')
    
    assert_equal(:result, dialog.next_state("that's it"))
    dialog.hear("that's it")
    
  end
end