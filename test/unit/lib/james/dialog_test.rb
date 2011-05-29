# encoding: utf-8
#
require 'minitest/autorun'
require 'minitest/mock'

require File.expand_path '../../../../../lib/james', __FILE__
require File.expand_path '../../../../../lib/james/state_api', __FILE__
require File.expand_path '../../../../../lib/james/dialog_api', __FILE__
require File.expand_path '../../../../../lib/james/dialog_internals', __FILE__
require File.expand_path '../../../../../lib/james/builtin/core_dialog', __FILE__
require File.expand_path '../../../../../lib/james/dialogs', __FILE__

describe James::Dialog do

  attr_reader :dialog

  describe 'two states' do
    before do
      @dialog ||= James.use_dialog do

        hear 'something' => :first

        state :first do
          hear 'something else' => :second
          into {}
          exit {}
        end

        state :second do
          hear 'yet something else' => :first
          into {}
          exit {}
        end

      end.new
    end
    
    describe '#state_for' do
      it 'delegates to the superclass' do
        assert_equal :first, dialog.state_for(:first).name
      end
      it 'returns nil' do
        assert_equal nil, dialog.state_for(:nonexistent)
      end
    end
  end
  
  describe 'hear with lambda' do
    before do
      class Test
        include James::Dialog
        
        def initialize
          @bla = 'some bla'
        end
        
        state :test do
          hear 'bla' => ->(){ @bla }
        end
      end
      @dialog ||= Test.new
    end
    it "is instance eval'd" do
      test_state = dialog.state_for :test
      test_state.hear 'bla' do |result|
        result.should == 'some bla'
      end
    end
  end
  
  describe 'initialization' do
    it 'can be included' do
      class Test
        include James::Dialog
        
        hear 'something' => :some_state
      end
    end
    
    it 'can be defined' do
      James.use_dialog do        
        hear 'something' => :some_state
        state :some_state do
          
        end
      end
    end
  end

end