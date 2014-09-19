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

  # force the use of Nokogiri 1.5.x to prevent conflicts with older versions of zlib
  s.add_dependency 'nokogiri', '~>1.5'
  # force the use of rbvmomi 1.6.x to get around this issue: https://github.com/vmware/rbvmomi/pull/32
  s.add_dependency 'rbvmomi', '~> 1.6.0'
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
