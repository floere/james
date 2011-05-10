module James

  # A dialog(ue) can be instantiated in two ways:
  #
  # James.dialogue do
  #   # Your dialogue.
  #   #
  # end
  #
  # class MyDialogue
  #   include James::Dialogue
  #
  #   # Your dialogue.
  #   #
  # end
  #
  module Dialogue; end

  class << self

    def dialogue &block
      dialogue = Class.new { include James::Dialogue }
      dialogue.class_eval &block
      dialogue
    end
    alias dialog dialogue

  end

end