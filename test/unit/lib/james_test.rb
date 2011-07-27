# encoding: utf-8
#
require File.expand_path '../../../../lib/james', __FILE__

require 'minitest/autorun'
require 'minitest/unit'

describe James do

  describe 'with stubbed controller' do
    describe 'listen' do
      it 'can be called without options' do
        James.listen
      end
    end
  end

end