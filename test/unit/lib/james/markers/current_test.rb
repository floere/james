# encoding: utf-8
#
require File.expand_path '../../../../../../lib/james', __FILE__

describe James::Markers::Current do

  attr_reader :marker, :initial

  before do
    @initial ||= MiniTest::Mock.new
    @marker  ||= James::Markers::Current.new @initial
  end

  describe 'current' do
    it 'is the initial state' do
      assert_equal initial, marker.current
    end
  end

  describe 'enter' do
    it 'calls enter on the state' do
      initial.expect :__into__, nil

      marker.enter
    end
    it 'returns the result' do
      initial.expect :__into__, 'some text'

      assert_equal 'some text', marker.enter
    end
    it 'yields the result' do
      initial.expect :__into__, 'some text'

      marker.enter do |text|
        assert_equal 'some text', text
      end
    end
  end

  describe 'exit' do
    it 'calls enter on the state' do
      initial.expect :__exit__, nil, []

      marker.exit
    end
    it 'returns the result' do
      initial.expect :__exit__, 'some text'

      assert_equal 'some text', marker.exit
    end
    it 'yields the result' do
      initial.expect :__exit__, 'some text'

      marker.exit do |text|
        assert_equal 'some text', text
      end
    end
  end

  describe 'transition' do
    it 'sets the current state' do
      initial.expect :next_for, :some_state, ['some phrase']

      marker.transition 'some phrase'

      assert_equal :some_state, marker.current
    end
  end

  # describe 'hear' do
  #   it 'calls methods in order' do
  #     marker.expect :hears?, true, [:some_phrase]
  #     marker.expect :exit, nil, []
  #     marker.expect :transition, nil, :some_phrase
  #     marker.expect :enter, nil, []
  #
  #     marker.hear :some_phrase
  #   end
  # end
end