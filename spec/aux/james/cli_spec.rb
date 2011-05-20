# encoding: utf-8
#
require File.expand_path '../../../../aux/james/cli', __FILE__

describe James::CLI do
  
  before(:each) do
    Dir.stub! :[] => ['test_dialog.rb', 'test_dialog.rb', 'test/test_dialog.rb']
  end
  
  let(:cli) { James::CLI.new }
  
  describe 'find_dialogs' do
    it 'returns the right ones' do
      cli.find_dialogs.should == ['test_dialog.rb', 'test_dialog.rb', 'test/test_dialog.rb']
    end
  end
  
end