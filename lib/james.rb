module James end

require File.expand_path '../james/state', __FILE__
require File.expand_path '../james/dialogue', __FILE__
require File.expand_path '../james/main_dialogue', __FILE__

require File.expand_path '../james/recognizers/audio', __FILE__

require File.expand_path '../james/controller', __FILE__

module James

  # Do I care about the spelling? No.
  #
  Dialog = Dialogue

end

