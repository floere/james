# encoding: utf-8
#
require File.expand_path '../../../../../lib/james/inputs/base', __FILE__
require File.expand_path '../../../../../lib/james/inputs/audio', __FILE__

describe James::Inputs::Audio do
  
  let(:input) { described_class.new }
  
  describe 'speechRecognizer' do
    it 'does something' do
      sender = stub :sender
      
      input.speechRecognizer sender
    end
  end
  
end