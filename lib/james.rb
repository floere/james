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

require File.expand_path '../james/controller', __FILE__

module James

  # Start a new controller and listen.
  #
  # Will not listen again if already listening.
  #
  def self.listen
    return if @controller && @controller.listening?
    @controller ||= Controller.new
    @controller.listen
  end

end
