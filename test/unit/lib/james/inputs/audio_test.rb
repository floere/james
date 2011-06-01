# encoding: utf-8
#
require File.expand_path '../../../../../../lib/james/inputs/base', __FILE__
require File.expand_path '../../../../../../lib/james/inputs/audio', __FILE__

describe James::Inputs::Audio do

  attr_reader :input

  before do
    controller = MiniTest::Mock.new
    controller.expect :hear, nil, [:some_command]

    @input ||= James::Inputs::Audio.new controller
  end

  # describe 'speechRecognizer' do
  #   it 'does something' do
  #     input.speechRecognizer :sender, didRecognizeCommand: :some_command
  #   end
  # end

end