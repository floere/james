# encoding: utf-8
#
require File.expand_path '../../../../../lib/james/visitors', __FILE__

describe James::Visitors do

  attr_reader :visitors, :first, :second

  before do
    @first    = Class.new(MiniTest::Mock).new
    @second   = Class.new(MiniTest::Mock).new
    @visitors = James::Visitors.new @first, @second
  end

  describe 'hear' do
    describe 'the first has it' do
      it 'calls the second never' do
        first.expect  :hear,  :something, ['some phrase']
        second.expect :reset, nil

        visitors.hear 'some phrase'
      end
    end
    describe 'the second has it' do
      it 'works' do
        first.expect  :hear, nil,        ['some phrase']
        second.expect :hear, :something, ['some phrase']

        visitors.hear 'some phrase'
      end
      it 'calls the first hear first' do
        first.expect  :hear, nil, ['some phrase']
        second.expect :hear, nil, ['some phrase']

        visitors.hear 'some phrase'
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
        assert_equal [:c, :d, :e, :a, :b], visitors.expects
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
        assert_equal [:a, :b], visitors.expects
      end
    end
  end

end