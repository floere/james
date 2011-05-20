module James

  # A dialog can be instantiated in two ways:
  #
  # The simple way, will directly add itself to James.
  #
  # James.use_dialog(optional_args_for_initialize) do
  #   # Your dialog.
  #   #
  # end
  #
  # class MyDialog
  #   include James::Dialog
  #
  #   # Your dialog.
  #   #
  # end
  #
  # James.use MyDialog.new
  #
  module Dialog; end

  class << self

    def use_dialog *args, &block
      dialog = Class.new { include James::Dialog }
      dialog.class_eval &block
      use dialog.new(*args)
      dialog
    end

  end

end