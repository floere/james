class Object

  #
  #
  def dialogue name
    if block_given?
      Dialogue.new &Proc.new
    else
      raise ArgumentError.new("The #{__method__} method needs a block in which the #{__method__} is defined.")
    end
  end
  alias dialog dialogue

end