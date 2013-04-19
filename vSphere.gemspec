
Gem::Specification.new do |s|
  s.name = 'vSphere Provider'

  s.add_dependency 'rbvmomi'

  s.add_development_dependency 'vagrant'
  s.add_development_dependency 'mocha'
  s.add_development_dependency 'rspec-core', '~> 2.13.0'
  s.add_development_dependency 'rspec-expectations', '~> 2.13.0'
  s.add_development_dependency 'rspec-mocks', '~> 2.13.0'
end