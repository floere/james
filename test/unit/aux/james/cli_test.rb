# encoding: utf-8
#
require 'minitest/autorun'
require 'minitest/mock'

require File.expand_path '../../../../../aux/james/cli', __FILE__

describe James::CLI do

  attr_reader :cli
  
  before do
    @cli = James::CLI.new
  end
  
  describe 'extract_options' do
    it 'sets the correct options' do
      expected = {}
      assert_equal expected, cli.extract_options(['quack', 'moo'])
    end
    it 'sets the correct options' do
      expected = { :input => James::Inputs::Terminal }
      assert_equal expected, cli.extract_options(['quack', '-si', 'moo'])
    end
    it 'sets the correct options' do
      expected = { :output => James::Outputs::Terminal }
      assert_equal expected, cli.extract_options(['quack', '-so', 'moo'])
    end
    it 'sets the correct options' do
      expected = { :input => James::Inputs::Terminal, :output => James::Outputs::Terminal }
      assert_equal expected, cli.extract_options(['-s', 'quack', 'moo'])
    end
    it 'sets the correct options' do
      expected = { :input => James::Inputs::Terminal, :output => James::Outputs::Terminal }
      assert_equal expected, cli.extract_options(['-s', 'quack', '-si', 'moo'])
    end
    it 'sets the correct options' do
      expected = { :input => James::Inputs::Terminal, :output => James::Outputs::Terminal }
      assert_equal expected, cli.extract_options(['-s', 'quack', '-so', 'moo'])
    end
    it 'sets the correct options' do
      expected = { :input => James::Inputs::Terminal, :output => James::Outputs::Terminal }
      assert_equal expected, cli.extract_options(['-s', 'quack', '-so', 'moo', '-si'])
    end
  end
  
end