# encoding: utf-8
#
require File.expand_path '../../../lib/james', __FILE__

require 'minitest/autorun'

describe 'TestDialog' do

  attr_reader :visitor

  describe 'unit' do
    before do
      dialog = Class.new do
        include James::Dialog

        hear ['test1', 'test2'] => :first

        state :first do
          hear 'go' => :second, 'stay' => :first
        end

        state :second do
          hear 'go' => :third, 'back' => :first
        end
      end.new

      @visitor = James::Visitor.new dialog.state_for(:first)
    end

    describe "integration" do
      it 'works correctly' do
        assert_equal :first, visitor.current.name
        visitor.hear('go') {}
        assert_equal :second, visitor.current.name
        visitor.hear('back') {}
        assert_equal :first, visitor.current.name
        visitor.hear('stay') {}
        assert_equal :first, visitor.current.name
      end
    end
  end

  describe 'integration' do
    before do
      dialog = Class.new do
        include James::Dialog

        hear ['test1', 'test2'] => :first
        state :first do
          hear 'stay'
        end
        state :second do
          hear 'go' => :third, 'back' => :first
        end
      end.new

      @visitor = James::Visitor.new dialog.state_for(:first)
    end
    it 'works correctly' do
      assert_equal :first, visitor.current.name
      visitor.hear 'stay'
      assert_equal :first, visitor.current.name
    end
  end

end