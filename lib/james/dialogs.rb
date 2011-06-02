module James

  # Bundles a bunch of dialogs.
  #
  class Dialogs

    attr_reader :dialogs

    def initialize *dialogs
      @dialogs = dialogs
    end

    #
    #
    def chain_to incoming_dialog
      dialogs.each { |dialog| incoming_dialog << dialog }
    end

  end

end