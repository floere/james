# encoding: utf-8
#
require File.expand_path '../../../../lib/james/dialogue_api', __FILE__
require File.expand_path '../../../../lib/james/dialogue_internals', __FILE__
require File.expand_path '../../../../lib/james/builtin/core_dialogue', __FILE__
require File.expand_path '../../../../lib/james/dialogues', __FILE__

describe James::Dialogue do
  
  it 'can haz merkin spellink' do
    James::Dialogue.should == James::Dialog
  end
  
  context 'units' do
    let(:dialogue) do
      James.dialogue do
        
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
        new_dialogue = dialogue.new
        dialogue.should_receive(:state_for).once.with :some_name, new_dialogue
        
        new_dialogue.state_for :some_name
      end
      it 'returns nil on not found' do
        dialogue.new.state_for(:nonexistent).should == nil
      end
    end
  end
  
  describe 'initialization' do
    it 'can be included' do
      expect do
        class Test
          include James::Dialogue
          
          hear 'something' => :some_state
        end
      end.to_not raise_error
    end
    
    it 'can be defined' do
      expect do
        James.dialogue do
          
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