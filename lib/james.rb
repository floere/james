module James; end

# require File.expand_path '../james/timer', __FILE__

require File.expand_path '../james/state_api', __FILE__
require File.expand_path '../james/state_internals', __FILE__

require File.expand_path '../james/visitor', __FILE__
require File.expand_path '../james/visitors', __FILE__

require File.expand_path '../james/dialog_api', __FILE__
require File.expand_path '../james/dialog_internals', __FILE__

require File.expand_path '../james/dialogs', __FILE__

require File.expand_path '../james/inputs/base', __FILE__
require File.expand_path '../james/inputs/audio', __FILE__
require File.expand_path '../james/inputs/terminal', __FILE__

require File.expand_path '../james/outputs/audio', __FILE__
require File.expand_path '../james/outputs/terminal', __FILE__

require File.expand_path '../james/builtin/core_dialog', __FILE__

require File.expand_path '../james/framework', __FILE__
require File.expand_path '../james/controller', __FILE__

module James

  # Use the given dialogs.
  #
  # If called twice or more, will just add more dialogs.
  #
  def self.use *dialogs
    dialogs.each { |dialog| controller.add_dialog dialog }
  end

  # Start listening.
  #
  # Will not listen again if already listening.
  #
  def self.listen options
    controller.listen options
  end

  # Controller instance.
  #
  def self.controller
    @controller ||= Controller.new
  end

end
