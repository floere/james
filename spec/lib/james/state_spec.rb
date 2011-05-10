# encoding: utf-8
#
require File.expand_path '../../../../lib/james/state_api', __FILE__
require File.expand_path '../../../../lib/james/state_internals', __FILE__

describe James::State do
  
  before(:all) do
    @context = stub :context,
                    :inspect => 'some_context'
    class << @context
      
      def state_for name
        {
          :next_state1 => :some_state_object1,
          :next_state2 => :some_state_object2,
          :next_state3 => :some_state_object3,
        }[name]
      end
      
    end
  end
  
  context 'with no transitions or into or exit' do
    let(:state) do
      described_class.new :some_name, @context do
        # Nothing to see here.
      end
    end
    describe 'phrases' do
      it { state.phrases.should == [] }
    end
    describe 'to_s' do
      it { state.to_s.should == 'James::State(some_name, some_context, {})' }
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
    describe '__into__' do
      it 'is called' do
        state.__into__.should == nil
      end
    end
    describe '__exit__' do
      it 'is conditionally called' do
        state.__exit__.should == nil
      end
    end
  end
  
  context 'of the context' do
    let(:state) do
      described_class.new :some_name, @context do
        hear 'transition one' => :next_state1
        into { self }
        exit { self }
      end
    end
    describe '__into__' do
      it 'is called' do
        state.__into__.should == @context
      end
    end
    describe '__exit__' do
      it 'is conditionally called' do
        state.__exit__.should == @context
      end
    end
  end
  
  context 'with a returning transition' do
    let(:state) do
      described_class.new :some_name, @context do
        hear 'transition one' => lambda { "I do this and return to :some_name" }
      end
    end
    describe 'phrases' do
      it { state.phrases.should == ['transition one'] }
    end
  end
  
  context 'with 1 transition and into and exit' do
    let(:state) do
      described_class.new :some_name, @context do
        hear 'transition one' => :next_state1
        into { "hi there" }
        exit { "good bye" }
      end
    end
    describe 'phrases' do
      it { state.phrases.should == ['transition one'] }
    end
    describe 'to_s' do
      it { state.to_s.should == 'James::State(some_name, some_context, {"transition one"=>:next_state1})' }
    end
    describe 'next_for' do
      it { state.next_for('transition one').should == :some_state_object1 }
      it { state.next_for('non-existent').should == nil }
    end
    describe '__into__' do
      it 'is called' do
        state.__into__.should == 'hi there'
      end
    end
    describe '__exit__' do
      it 'is conditionally called' do
        state.__exit__.should == 'good bye'
      end
    end
  end
  
  context 'with multiple transition and separate hears' do
    let(:state) do
      described_class.new :some_name, @context do
        hear 'transition one'   => :next_state1,
             'transition two'   => :next_state2
        hear 'transition three' => :next_state3
      end
    end
    describe 'phrases' do
      it { state.phrases.should == ['transition one', 'transition two', 'transition three'] }
    end
    describe 'to_s' do
      it { state.to_s.should == 'James::State(some_name, some_context, {"transition one"=>:next_state1, "transition two"=>:next_state2, "transition three"=>:next_state3})' }
    end
    it { state.next_for('transition two').should == :some_state_object2 }
    it { state.next_for('transition three').should == :some_state_object3 }
    it { state.next_for('non-existent').should == nil }
  end
  
end