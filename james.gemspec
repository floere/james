# encoding: utf-8
#

Gem::Specification.new do |s|
  # Removed. Possible to enable for 10.5, 10.6 at the same time?
  #
  # s.platform = ['universal', 'darwin', nil]

  s.name = 'james'
  s.version = '0.7.1'

  s.author = 'Florian Hanke'
  s.email = 'florian.hanke+james@gmail.com'

  s.homepage = 'http://floere.github.com/james'

  s.description = 'Modular Electronic Butler. Using a simple dialog system where you can easily add more dialogs.'
  s.summary = 'James: Modular Electronic Butler with modular Dialogs.'

  s.files = Dir["lib/**/*.rb", "aux/**/*.rb"]
  s.test_files = Dir["spec/**/*_spec.rb"]

  s.executables = ['james']
  s.default_executable = 'james'

  s.add_development_dependency 'rspec'
end