# encoding: utf-8
#
require File.expand_path '../../../../../lib/james/state_api', __FILE__
require File.expand_path '../../../../../lib/james/state_internals', __FILE__

require 'minitest/autorun'
require 'minitest/unit'

describe James::State do

  before do
    @context = MiniTest::Mock.new

    class << @context

      def to_s
        'some_context'
      end

      def state_for name
        {
          :next_state1 => :some_state_object1,
          :next_state2 => :some_state_object2,
          :next_state3 => :some_state_object3,
        }[name]
      end

    end
  end

  attr_reader :state

  describe 'with no transitions or into or exit' do
    before do
      @state ||= James::State.new :some_name, @context do
        # Nothing to see here.
      end
    end
    describe 'phrases' do
      it '' do
        assert_equal [], state.phrases
      end
    end
    describe 'to_s' do
      it '' do
        assert_equal 'James::State(some_name, some_context, {})', state.to_s
      end
    end
    describe 'next_for' do
      it '' do
        assert_nil state.next_for('non-existent')
      end
    end
    describe 'expand' do
      it '' do
        expected = { :a => 1, :b => 1 }
        assert_equal expected, state.expand([:a, :b] => 1)
      end
      it '' do
        expected = { :a => 1 }
        assert_equal expected, state.expand(:a => 1)
      end
    end
    describe 'method __into__' do
      it 'is called' do
        assert_nil state.__into__
      end
    end
    describe 'method __exit__' do
      it 'is conditionally called' do
        assert_nil state.__exit__
      end
    end
  end

  describe 'of the context' do
    before do
      @state ||= James::State.new :some_name, @context do
        hear 'transition one' => :next_state1
        into { self }
        exit { self }
      end
    end
    describe 'method __into__' do
      it 'is called' do
        assert_equal @context, state.__into__
      end
    end
    describe 'method __exit__' do
      it 'is conditionally called' do
        assert_equal @context, state.__exit__
      end
    end
  end

  describe 'with a returning transition' do
    before do
      @state ||= James::State.new :some_name, @context do
        hear 'transition one' => lambda { "I do this and return to :some_name" }
      end
    end
    describe 'phrases' do
      it '' do
        assert_equal ['transition one'], state.phrases
      end
    end
  end

  describe 'with 1 transition and into and exit' do
    before do
      @state ||= James::State.new :some_name, @context do
        hear 'transition one' => :next_state1
        into { "hi there" }
        exit { "good bye" }
      end
    end
    describe 'phrases' do
      it '' do
        assert_equal ['transition one'], state.phrases
      end
    end
    describe 'to_s' do
      it '' do
        assert_equal 'James::State(some_name, some_context, {"transition one"=>:next_state1})', state.to_s
      end
    end
    describe 'next_for' do
      it '' do
        assert_equal :some_state_object1, state.next_for('transition one')
      end
      it '' do
        assert_nil state.next_for('non-existent')
      end
    end
    describe 'method __into__' do
      it 'is called' do
        assert_equal 'hi there', state.__into__
      end
    end
    describe 'method __exit__' do
      it 'is conditionally called' do
        assert_equal 'good bye', state.__exit__
      end
    end
  end

  describe 'raise on into/exit ArgumentError' do
    describe 'into' do
      it 'raises' do
        assert_raises ArgumentError do
          James::State.new :some_name, @context do
            hear 'transition one' => :next_state1
            into
          end
        end
      end
    end
    describe 'exit' do
      it 'raises' do
        assert_raises ArgumentError do
          James::State.new :some_name, @context do
            hear 'transition one' => :next_state1
            exit
          end
        end
      end
    end
  end

  describe 'with 1 transition and into and exit (both in text form)' do
    before do
      @state ||= James::State.new :some_name, @context do
        hear 'transition one' => :next_state1
        into "hi there"
        exit "good bye"
      end
    end
    describe 'phrases' do
      it '' do
        assert_equal ['transition one'], state.phrases
      end
    end
    describe 'to_s' do
      it '' do
        assert_equal 'James::State(some_name, some_context, {"transition one"=>:next_state1})', state.to_s
      end
    end
    describe 'next_for' do
      it '' do
        assert_equal :some_state_object1, state.next_for('transition one')
      end
      it '' do
        assert_nil state.next_for('non-existent')
      end
    end
    describe 'method __into__' do
      it 'is called' do
        assert_equal 'hi there', state.__into__
      end
    end
    describe 'method __exit__' do
      it 'is conditionally called' do
        assert_equal 'good bye', state.__exit__
      end
    end
  end

  describe 'with multiple transition and separate hears' do
    before do
      @state ||= James::State.new :some_name, @context do
        hear 'transition one'   => :next_state1,
             'transition two'   => :next_state2
        hear 'transition three' => :next_state3
      end
    end
    describe 'phrases' do
      it '' do
        assert_equal ['transition one', 'transition two', 'transition three'], state.phrases
      end
    end
    describe 'to_s' do
      it '' do
        assert_equal 'James::State(some_name, some_context, {"transition one"=>:next_state1, "transition two"=>:next_state2, "transition three"=>:next_state3})', state.to_s
      end
    end
    it '' do
      assert_equal :some_state_object2, state.next_for('transition two')
    end
    it '' do
      assert_equal :some_state_object3, state.next_for('transition three')
    end
    it '' do
      assert_nil state.next_for('non-existent')
    end
  end

  describe 'with self-transitions' do
    some_proc = ->(){ "Going back to where I came from" }
    before do
      @state ||= James::State.new :some_name, @context do
        hear 'transition one' => some_proc
      end
    end
    describe 'phrases' do
      it '' do
        assert_equal ['transition one'], state.phrases
      end
    end
    describe 'to_s' do
      it '' do
        assert_equal "James::State(some_name, some_context, {\"transition one\"=>#{some_proc}})", state.to_s
      end
    end
    it '' do
      assert_equal some_proc, state.next_for('transition one')
    end
    it '' do
      assert_nil state.next_for('non-existent')
    end
  end

end