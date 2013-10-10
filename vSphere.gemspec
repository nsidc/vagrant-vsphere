$:.unshift File.expand_path('../lib', __FILE__)
require 'vSphere/version'

Gem::Specification.new do |s|
  s.name = 'vagrant-vsphere'
  s.version = VagrantPlugins::VSphere::VERSION
  s.authors = ['Andrew Grauch']
  s.email = ['andrew.grauch@nsidc.org']
  s.homepage = ''
  s.license = 'MIT'
  s.summary = 'VMWare vSphere provider'
  s.description = 'Enables Vagrant to manage machines with VMWare vSphere.'
  
  s.add_dependency 'rbvmomi'
  s.add_dependency 'i18n', '~> 0.6.4'

  s.add_development_dependency 'rake'
  s.add_development_dependency 'rspec-core'
  s.add_development_dependency 'rspec-expectations'
  s.add_development_dependency 'rspec-mocks'
  
  s.files = `git ls-files`.split($/)
  s.executables = s.files.grep(%r{^bin/}) { |f| File.basename(f) }
  s.test_files = s.files.grep(%r{^(test|spec|features)/})
  s.require_path = 'lib'
end