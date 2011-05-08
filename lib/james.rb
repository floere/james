module James; end

# require File.expand_path '../james/state', __FILE__
require File.expand_path '../james/timer', __FILE__
require File.expand_path '../james/visitor', __FILE__
require File.expand_path '../james/dialogues', __FILE__

require File.expand_path '../james/dialogue_instantiation', __FILE__
require File.expand_path '../james/dialogue', __FILE__
# require File.expand_path '../james/main_dialogue', __FILE__

# require File.expand_path '../james/recognizers/base', __FILE__
# require File.expand_path '../james/recognizers/audio', __FILE__
# require File.expand_path '../james/recognizers/terminal', __FILE__

require File.expand_path '../james/controller', __FILE__

module James

  def self.listen
    Controller.new.listen
  end

end
