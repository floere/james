# encoding: utf-8
#
require File.expand_path '../../../lib/james', __FILE__

describe 'TestDialog' do

  context 'unit' do
    let(:dialog) do

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
      James::Visitor.new dialog.state_for(:first)
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
  #   let(:dialog) do
  #     dialog = Class.new do
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
  #     dialog.state.name.should == :awake
  #     dialog.hear 'sleep'
  #     dialog.state.name.should == :sleeping
  #   end
  #   it 'delegates correctly' do
  #     dialog.state.name.should == :awake
  #     dialog.hear 'test1'
  #   end
  # end

end