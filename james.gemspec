# encoding: utf-8
#

Gem::Specification.new do |s|
  s.platform = Gem::Platform::CURRENT

  s.name = 'james'
  s.version = '0.0.1'

  s.author = 'Florian Hanke'
  s.email = 'florian.hanke+james@gmail.com'

  s.homepage = 'http://floere.github.com/james'

  s.description = 'Modular Electronic Butler. Add Dialog(ue)s to it to add more abilities to it.'
  s.summary = 'James: Modular Electronic Butler.'

  s.files = Dir["lib/**/*.rb", "aux/**/*.rb"]
  s.test_files = Dir["spec/**/*_spec.rb"]

  s.add_development_dependency 'rspec'
end