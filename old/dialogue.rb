class Dialogue
  
  # choose one reply randomly from the given replies
  def random_reply(replies)
    replies[rand(replies.size)]
  end
  
end