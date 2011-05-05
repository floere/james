# encoding: utf-8
#
require 'spec_helper'

describe 'TestDialogue' do

  context 'unit' do
    let(:dialogue) do

      Class.new do
        include James::Dialog

        hooks 'test1', 'test2'
        state :first,  { 'go' => :second, 'stay' => :first }
        state :second, { 'go' => :third,  'back' => :first }
        initial :first
      end.new

    end

    describe "integration" do
      it 'works correctly' do
        dialogue.state.name.should == :first
        dialogue.hear 'go'
        dialogue.state.name.should == :second
        dialogue.hear 'back'
        dialogue.state.name.should == :first
        dialogue.hear 'stay'
        dialogue.state.name.should == :first
      end
      it 'calls the entrance/exits correctly' do
        dialogue.should_receive(:respond_to?).once.with(:enter_second).and_return true
        dialogue.should_receive(:enter_second).once

        dialogue.should_receive(:respond_to?).once.with(:exit_second).and_return true
        dialogue.should_receive(:exit_second).once

        dialogue.should_receive(:respond_to?).once.with(:enter_first).and_return true
        dialogue.should_receive(:enter_first).once

        dialogue.should_receive(:respond_to?).once.with(:exit_first).and_return true
        dialogue.should_receive(:exit_first).once

        dialogue.hear 'go'
        dialogue.hear 'back'
      end
    end
  end
  
  context 'integration' do
    let(:dialogue) do
      dialogue = Class.new do
        include James::Dialog

        hooks 'test1', 'test2'
        state :first,  { 'go' => :second, 'stay' => :first }
        state :second, { 'go' => :third,  'back' => :first }
        initial :first
      end.new
      
      James::MainDialogue.new
    end
    it 'works correctly' do
      dialogue.state.name.should == :awake
      dialogue.hear 'sleep'
      dialogue.state.name.should == :sleeping
    end
    it 'delegates correctly' do
      dialogue.state.name.should == :awake
      dialogue.hear 'test1'
    end
  end

end