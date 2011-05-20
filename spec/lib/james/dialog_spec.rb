# encoding: utf-8
#
require File.expand_path '../../../../lib/james', __FILE__
require File.expand_path '../../../../lib/james/state_api', __FILE__
require File.expand_path '../../../../lib/james/dialog_api', __FILE__
require File.expand_path '../../../../lib/james/dialog_internals', __FILE__
require File.expand_path '../../../../lib/james/builtin/core_dialog', __FILE__
require File.expand_path '../../../../lib/james/dialogs', __FILE__

describe James::Dialog do
  
  it 'can haz merkin spellink' do
    James::Dialog.should == James::Dialog
  end
  
  context 'units' do
    let(:dialog) do
      James.use_dialog do
        
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
        
      end
    end
    describe 'state_for' do
      it 'delegates to the class, adding itself' do
        new_dialog = dialog.new
        dialog.should_receive(:state_for).once.with :some_name, new_dialog
        
        new_dialog.state_for :some_name
      end
      it 'returns nil on not found' do
        dialog.new.state_for(:nonexistent).should == nil
      end
    end
  end
  
  describe 'hear with lambda' do
    let(:dialog) do
      class Test
        include James::Dialog
        
        def initialize
          @bla = 'some bla'
        end
        
        state :test do
          hear 'bla' => ->(){ @bla }
        end
      end
      Test.new
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
      expect do
        class Test
          include James::Dialog
          
          hear 'something' => :some_state
        end
      end.to_not raise_error
    end
    
    it 'can be defined' do
      expect do
        James.dialog do
          
          hear 'something' => :some_state
          
        end
      end.to_not raise_error
    end
    it 'can haz merkin spellink' do
      expect do
        James.dialog do
          
          hear 'something' => :some_state
          
        end
      end.to_not raise_error
    end
  end
  
end