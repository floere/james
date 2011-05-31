# encoding: utf-8
#
require File.expand_path '../../../../../lib/james/visitor', __FILE__

describe James::Visitor do

  attr_reader :visitor, :initial

  before do
    @initial ||= MiniTest::Mock.new
    @visitor ||= James::Visitor.new @initial
  end

  describe 'reset' do
    it 'works' do
      visitor.reset
    end
    # it 'calls methods in order' do
    #   timer.should_receive(:stop).once.with
    #   visitor.should_receive(:current=).once.with initial
    #
    #   visitor.reset
    # end
    it 'survives a functional test' do
      next_state = MiniTest::Mock.new
      initial.expect :next_for, next_state, ['some phrase']

      assert_equal initial, visitor.current

      visitor.transition 'some phrase'

      assert_equal next_state, visitor.current

      visitor.reset

      assert_equal initial, visitor.current
    end
  end

  describe 'current' do
    it 'is the initial state' do
      assert_equal initial, visitor.current
    end
  end

  describe 'enter' do
    it 'calls enter on the state' do
      initial.expect :__into__, nil

      visitor.enter
    end
    it 'returns the result' do
      initial.expect :__into__, 'some text'

      assert_equal 'some text', visitor.enter
    end
    it 'yields the result' do
      initial.expect :__into__, 'some text'

      visitor.enter do |text|
        assert_equal 'some text', text
      end
    end
  end

  describe 'exit' do
    it 'calls enter on the state' do
      initial.expect :__exit__, nil, []

      visitor.exit
    end
    it 'returns the result' do
      initial.expect :__exit__, 'some text'

      assert_equal 'some text', visitor.exit
    end
    it 'yields the result' do
      initial.expect :__exit__, 'some text'

      visitor.exit do |text|
        assert_equal 'some text', text
      end
    end
  end

  describe 'transition' do
    it 'sets the current state' do
      initial.expect :next_for, :some_state, ['some phrase']

      visitor.transition 'some phrase'

      assert_equal :some_state, visitor.current
    end
  end

  # describe 'hear' do
  #   it 'calls methods in order' do
  #     visitor.expect :hears?, true, [:some_phrase]
  #     visitor.expect :exit, nil, []
  #     visitor.expect :transition, nil, :some_phrase
  #     visitor.expect :enter, nil, []
  #
  #     visitor.hear :some_phrase
  #   end
  # end
end