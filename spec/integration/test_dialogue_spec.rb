# encoding: utf-8
#
require File.expand_path '../../../lib/james', __FILE__

describe 'TestDialogue' do

  context 'unit' do
    let(:dialogue) do

      Class.new do
        include James::Dialog

        hear ['test1', 'test2'] => :first
        
        state :first do
          hear 'go' => :second, 'stay' => :first
        end
        
        state :second do
          hear 'go' => :third, 'back' => :first
        end
      end.new

    end
    let(:visitor) do
      James::Visitor.new dialogue.state_for(:first)
    end

    describe "integration" do
      it 'works correctly' do
        visitor.current.name.should == :first
        visitor.hear('go') {}
        visitor.current.name.should == :second
        visitor.hear('back') {}
        visitor.current.name.should == :first
        visitor.hear('stay') {}
        visitor.current.name.should == :first
      end
    end
  end
  
  # context 'integration' do
  #   let(:dialogue) do
  #     dialogue = Class.new do
  #       include James::Dialog
  # 
  #       hear ['test1', 'test2'] => :first
  #       state :first do
  #         hear 'go' => :second, 'stay' => :first
  #       end
  #       state :second do
  #         hear 'go' => :third, 'back' => :first
  #       end
  #     end.new
  #   end
  #   it 'works correctly' do
  #     dialogue.state.name.should == :awake
  #     dialogue.hear 'sleep'
  #     dialogue.state.name.should == :sleeping
  #   end
  #   it 'delegates correctly' do
  #     dialogue.state.name.should == :awake
  #     dialogue.hear 'test1'
  #   end
  # end

end