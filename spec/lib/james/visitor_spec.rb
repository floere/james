# encoding: utf-8
#
require File.expand_path '../../../../lib/james/visitor', __FILE__

describe James::Visitor do
  
  let(:initial) { stub :state }
  let(:timer)   { stub :timer }
  let(:visitor) { described_class.new initial, timer }
  
  describe 'current' do
    it { visitor.current.should == initial }
  end
  
  describe 'enter' do
    it 'calls enter on the state' do
      initial.should_receive(:enter).once
      
      visitor.enter
    end
    it 'returns the result' do
      initial.stub! :enter => 'some text'
      
      visitor.enter.should == 'some text'
    end
    it 'yields the result' do
      initial.stub! :enter => 'some text'
      
      visitor.enter do |text|
        text.should == 'some text'
      end
    end
  end
  
  describe 'exit' do
    it 'calls enter on the state' do
      initial.should_receive(:exit).once.with('some phrase')
      
      visitor.exit 'some phrase'
    end
    it 'returns the result' do
      initial.stub! :exit => 'some text'
      
      visitor.exit('some phrase').should == 'some text'
    end
    it 'yields the result' do
      initial.stub! :exit => 'some text'
      
      visitor.exit('some phrase') do |text|
        text.should == 'some text'
      end
    end
  end
  
  describe 'hear' do
    it 'calls methods in order' do
      timer.should_receive(:reset).once.ordered.with
      visitor.should_receive(:exit).once.ordered.with(:some_phrase)
      visitor.should_receive(:transition).once.ordered.with(:some_phrase)
      visitor.should_receive(:check).once.ordered.with
      visitor.should_receive(:enter).once.ordered.with
      
      visitor.hear :some_phrase
    end
  end
end