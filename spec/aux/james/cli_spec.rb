# encoding: utf-8
#
require File.expand_path '../../../../aux/james/cli', __FILE__

describe James::CLI do
  
  before(:each) do
    Dir.stub! :[] => ['test_dialogue.rb', 'test_dialog.rb', 'test/test_dialogue.rb']
  end
  
  let(:cli) { James::CLI.new }
  
  describe 'find_dialogues' do
    it 'returns the right ones' do
      cli.find_dialogues.should == ['test_dialogue.rb', 'test_dialog.rb', 'test/test_dialogue.rb']
    end
  end
  
end