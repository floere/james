# encoding: utf-8
#
require 'minitest/autorun'
require 'minitest/mock'

require File.expand_path '../../../../../lib/james', __FILE__
require File.expand_path '../../../../../lib/james/state_api', __FILE__
require File.expand_path '../../../../../lib/james/dialog_api', __FILE__
require File.expand_path '../../../../../lib/james/dialog_internals', __FILE__
require File.expand_path '../../../../../lib/james/builtin/core_dialog', __FILE__
require File.expand_path '../../../../../lib/james/dialogs', __FILE__

describe James::Dialog do

  attr_reader :dialog

  describe 'no states' do
    before do
      @dialog ||= Class.new do

        include James::Dialog

      end.new
    end

    describe '#chain_to' do
      it 'does not chain anything (except warn)' do
        state = MiniTest::Mock.new

        dialog.chain_to state
      end
    end

  end

  describe 'two states, one is chainable' do
    before do
      @dialog ||= Class.new do

        include James::Dialog

        hear 'something' => :first

        state :first do
          hear 'something else' => :second
          into {}
          exit {}
        end

        state :second do

          chainable

          hear 'yet something else' => :first
          into {}
          exit {}
        end

      end.new
    end

    describe '.states' do
      it 'is correct' do
        expected = { :first => dialog.class.states[:first], :second => dialog.class.states[:second] }
        assert_equal expected, dialog.class.states
      end
    end

    describe '#chain_to' do
      it 'chains the dialog to the given state' do
        state = MiniTest::Mock.new

        state.expect :hear, nil, ['something' => dialog.state_for(:second)]

        dialog.chain_to state
      end
    end

    describe '#<<' do
      it 'chains the given dialog to all chainable states' do
        following_dialog = MiniTest::Mock.new

        following_dialog.expect :chain_to, nil, [dialog.state_for(:second)]

        dialog << following_dialog
      end
    end

    describe '#state_for' do
      it 'delegates to the superclass' do
        assert_equal :first, dialog.state_for(:first).name
      end
      it 'returns nil' do
        assert_equal nil, dialog.state_for(:nonexistent)
      end
      it 'returns the state if it is already an instance' do
        state = dialog.state_for :first

        assert_equal state, dialog.state_for(state)
      end
    end
  end

  describe 'hear with lambda' do
    before do
      class Test
        include James::Dialog

        def initialize
          @bla = 'some bla'
        end

        state :test do
          hear 'bla' => ->(){ @bla }
        end
      end
      @dialog ||= Test.new
    end

    it "is instance eval'd" do
      test_state = dialog.state_for :test
      test_state.hear 'bla' do |result|
        result.should == 'some bla'
      end
    end
  end

  describe 'initialization' do
    it 'can be included' do
      class Test
        include James::Dialog

        hear 'something' => :some_state
      end
    end

    it 'can be defined' do
      Class.new do

        include James::Dialog

        hear 'something' => :some_state
        state :some_state do

        end
      end
    end
  end

end