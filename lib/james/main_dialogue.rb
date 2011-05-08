module James

  # MainDialogue for first visitor.
  #
  module MainDialogue

    extend Dialogue

    def self.included into
      into.extend ClassMethods
    end

  end

end