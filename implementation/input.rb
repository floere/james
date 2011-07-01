framework 'AppKit'

recognizer = NSSpeechRecognizer.alloc.init
recognizer.setDelegate self
def speechRecognizer sender, didRecognizeCommand: command
  puts "I heard the command #{command}!"
end
recognizer.setCommands [
  "Hello, James",
  "How are you?",
  "Nice weather, isn't it?"
]
recognizer.startListening
