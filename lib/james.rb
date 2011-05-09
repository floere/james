module James; end

require File.expand_path '../james/timer', __FILE__
require File.expand_path '../james/visitor', __FILE__
require File.expand_path '../james/dialogues', __FILE__

require File.expand_path '../james/dialogue_api', __FILE__
require File.expand_path '../james/dialogue_internals', __FILE__

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
