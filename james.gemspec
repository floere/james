# encoding: utf-8
#

Gem::Specification.new do |s|
  s.platform = Gem::Platform::CURRENT

  s.name = 'james'
  s.version = '0.1.0'

  s.author = 'Florian Hanke'
  s.email = 'florian.hanke+james@gmail.com'

  s.homepage = 'http://floere.github.com/james'

  s.description = 'Modular Electronic Butler. Using a simple dialogue system where you can easily add more dialogues.'
  s.summary = 'James: Modular Electronic Butler with modular Dialogues.'

  s.files = Dir["lib/**/*.rb", "aux/**/*.rb"]
  s.test_files = Dir["spec/**/*_spec.rb"]

  s.executables = ['james']
  s.default_executable = 'james'

  s.add_development_dependency 'rspec'
end