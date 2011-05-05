framework 'AppKit'

class AppDelegate
  def applicationDidFinishLaunching(notification)
    voice_type = "com.apple.speech.synthesis.voice.GoodNews"
    @voice = NSSpeechSynthesizer.alloc.initWithVoice(voice_type)
  end

  def windowWillClose(notification)
    puts "Bye!"
    exit
  end

  def say_hello(sender)
    @voice.startSpeakingString("Hello World!")
    puts "Hello World!"
  end
end

app = NSApplication.sharedApplication
app.delegate = AppDelegate.new

# window = NSWindow.alloc.initWithContentRect([200, 300, 300, 100],
#     styleMask:NSTitledWindowMask|NSClosableWindowMask|NSMiniaturizableWindowMask,
#     backing:NSBackingStoreBuffered,
#     defer:false)
# window.title      = 'MacRuby: The Definitive Guide'
# window.level      = 3
# window.delegate   = app.delegate
#
# button = NSButton.alloc.initWithFrame([80, 10, 120, 80])
# button.bezelStyle = 4
# button.title      = 'Hello World!'
# button.target     = app.delegate
# button.action     = 'say_hello:'
#
# window.contentView.addSubview(button)
#
# window.display
# window.orderFrontRegardless

app.delegate.applicationDidFinishLaunching nil

app.delegate.say_hello app.delegate

app.run