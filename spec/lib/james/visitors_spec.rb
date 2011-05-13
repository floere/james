# encoding: utf-8
#
require File.expand_path '../../../../lib/james/visitors', __FILE__

describe James::Visitors do
  
  let(:first)    { stub :first  }
  let(:second)   { stub :second }
  let(:visitors) { described_class.new first, second }
  
  describe 'hear' do
    context 'the first has it' do
      before(:each) do
        first.stub!  :hear => :something
        second.stub! :hear => nil
      end
      it 'works' do
        second.stub! :reset
        
        visitors.hear 'some phrase'
      end
      it 'calls the second never' do
        first.should_receive(:hear).once.and_return true
        second.should_receive(:hear).never
        second.should_receive(:reset).once
        
        visitors.hear 'some phrase'
      end
    end
    context 'the second has it' do
      before(:each) do
        first.stub!  :hear => nil
        second.stub! :hear => :something
      end
      it 'works' do
        visitors.hear 'some phrase'
      end
      it 'calls the first hear first' do
        first.should_receive(:hear).once.ordered.with 'some phrase'
        second.should_receive(:hear).once.ordered.with 'some phrase'
        
        visitors.hear 'some phrase'
      end
    end
  end
  
  describe 'expects' do
    context 'chainable' do
      before(:each) do
        first.stub!  :expects => [:a, :b], :chainable? => true
        second.stub! :expects => [:c, :d, :e], :chainable? => true
      end
      it { visitors.expects.should == [:c, :d, :e, :a, :b] }
    end
    context 'not chainable' do
      before(:each) do
        first.stub!  :expects => [:a, :b], :chainable? => false
        second.stub! :expects => [:c, :d, :e], :chainable? => false
      end
      it { visitors.expects.should == [:a, :b] }
    end
  end

end