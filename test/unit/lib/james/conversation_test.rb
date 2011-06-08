# encoding: utf-8
#
require File.expand_path '../../../../../lib/james', __FILE__

describe James::Conversation do

  attr_reader :conversation, :first, :second

  before do
    @first        = Class.new(MiniTest::Mock).new
    @second       = Class.new(MiniTest::Mock).new
    @conversation = James::Conversation.new @first
    @conversation.markers = [@first, @second]
  end

  describe 'hear' do
    describe 'the first has it' do
      it 'calls the second never' do
        new_marker = Class.new(MiniTest::Mock).new
        new_marker.expect :current?, true

        first.expect  :hear,  [new_marker], ['some phrase']

        conversation.hear 'some phrase'
      end
    end
    describe 'the second has it' do
      it 'works' do
        first.expect  :hear, [], ['some phrase']
        second.expect :hear, [], ['some phrase']

        conversation.hear 'some phrase'
      end
    end
  end

  describe 'expects' do
    describe 'chainable' do
      before do
        second.expect :expects, [:c, :d, :e]
        second.expect :chainable?, true
        first.expect  :expects, [:a, :b]
        first.expect  :chainable?, true
      end
      it '' do
        assert_equal [:c, :d, :e, :a, :b], conversation.expects
      end
    end
    describe 'not chainable' do
      before do
        first.expect  :expects, [:a, :b]
        first.expect  :chainable?, false
        second.expect :expects, [:c, :d, :e]
        second.expect :chainable?, false
      end
      it '' do
        assert_equal [:a, :b], conversation.expects
      end
    end
  end

end