# encoding: utf-8
#
require 'minitest/autorun'
require 'minitest/mock'

require File.expand_path '../../../../../lib/james/dialog_api', __FILE__
require File.expand_path '../../../../../lib/james/dialog_internals', __FILE__
require File.expand_path '../../../../../lib/james/builtin/core_dialog', __FILE__
require File.expand_path '../../../../../lib/james/visitors', __FILE__
require File.expand_path '../../../../../lib/james/visitor', __FILE__
require File.expand_path '../../../../../lib/james/state_api', __FILE__
require File.expand_path '../../../../../lib/james/dialogs', __FILE__
require File.expand_path '../../../../../lib/james/inputs/base', __FILE__
require File.expand_path '../../../../../lib/james/inputs/terminal', __FILE__
require File.expand_path '../../../../../lib/james/inputs/audio', __FILE__
require File.expand_path '../../../../../lib/james/controller', __FILE__

describe James::Controller do

  attr_reader :controller

  before do
    @controller = James::Controller.instance
  end

  describe 'listening' do
    it 'is correct' do
      assert_equal nil, controller.listening
    end
    # it 'is correct' do
    #   controller.listen
    #   assert_equal true, controller.listening
    # end
  end
  # describe 'expects' do
  #   it 'delegates' do
  #     visitor = stub! :visitor
  #     controller.stub! :visitor => visitor
  #
  #     visitor.should_receive(:expects).once.with()
  #
  #     controller.expects
  #   end
  # end

end