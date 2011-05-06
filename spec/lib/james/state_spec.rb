# encoding: utf-8
#
require File.expand_path '../../../../lib/james/state', __FILE__

describe James::State do
  
  before(:all) do
    @context = Class.new do
      def to_s
        'some context'
      end
      def state_for phrase
        {
          :next_state1 => :some_state_object1,
          :next_state2 => :some_state_object2,
          :next_state3 => :some_state_object3
        }[phrase]
      end
    end.new
  end
  
  context 'with no transitions' do
    let(:state) { described_class.new :some_name, @context }
    describe 'phrases' do
      it { state.phrases.should == [] }
    end
    describe 'to_s' do
      it { state.to_s.should == 'James::State(some_name, some context, {})' }
    end
    describe 'next_for' do
      it { state.next_for('non-existent').should == nil }
    end
    describe 'expand' do
      it do
        state.expand([:a, :b] => 1).should == { :a => 1, :b => 1 }
      end
      it do
        state.expand(:a => 1).should == { :a => 1 }
      end
    end
    describe 'enter' do
      it 'is conditionally called' do
        state.enter.should == nil # Order is important? UGH.
      end
      it 'is conditionally called' do
        @context.stub! :enter_some_name => 'some answer'
        
        state.enter.should == 'some answer'
      end
    end
    describe 'exit' do
      it 'is conditionally called' do
        state.exit('phrase').should == nil # Order is important? UGH.
      end
      it 'is conditionally called' do
        @context.stub! :exit_some_name => 'some answer'
        
        state.exit('phrase').should == 'some answer'
      end
    end
  end
  
  context 'with 1 transition' do
    let(:state) { described_class.new :some_name, @context, { 'transition one' => :next_state1 } }
    describe 'phrases' do
      it { state.phrases.should == ['transition one'] }
    end
    describe 'to_s' do
      it { state.to_s.should == 'James::State(some_name, some context, {"transition one"=>:next_state1})' }
    end
    describe 'next_for' do
      it { state.next_for('transition one').should == :some_state_object1 }
      it { state.next_for('non-existent').should == nil }
    end
  end
  
  context 'with multiple transition' do
    let(:state) do
      described_class.new :some_name, @context, {
        'transition one' => :next_state1,
        'transition two' => :next_state2,
        'transition three' => :next_state3
      }
    end
    describe 'phrases' do
      it { state.phrases.should == ['transition one', 'transition two', 'transition three'] }
    end
    describe 'to_s' do
      it { state.to_s.should == 'James::State(some_name, some context, {"transition one"=>:next_state1, "transition two"=>:next_state2, "transition three"=>:next_state3})' }
    end
    it { state.next_for('transition two').should == :some_state_object2 }
    it { state.next_for('non-existent').should == nil }
  end
  
end