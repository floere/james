# encoding: utf-8
#
require File.expand_path '../../../../../lib/james/preferences', __FILE__

require 'minitest/autorun'
require 'minitest/unit'

describe James::Preferences do

  # The dotfile in my home dir overrides this.
  #
  # describe 'without a dotfile in the current dir' do
  #   before do
  #     @preferences = James::Preferences.new
  #   end
  #   it 'uses the default voice' do
  #     assert_equal 'com.apple.speech.synthesis.voice.Alex', @preferences.voice
  #   end
  # end

  describe 'with a dotfile in the current dir' do
    before do
      @old_dir = Dir.pwd
      Dir.chdir 'test/data'
      @preferences = James::Preferences.new
    end
    after do
      Dir.chdir @old_dir
    end
    it 'sets the voice' do
      assert_equal 'some.voice', @preferences.voice
    end
  end

  # describe 'with a dotfile in the home dir' do
  #   
  # end

end