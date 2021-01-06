$LOAD_PATH.unshift File.expand_path('../lib', __FILE__)
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

  # pin nokogiri to 1.10.10 to get around 1.11.0 requiring ruby >=2.5
  s.add_dependency 'nokogiri', '1.10.10'

  s.add_dependency 'rbvmomi', '>=1.11.5', '<2.0.0'

  s.add_dependency 'i18n', '>=0.6.4'

  s.add_development_dependency 'rake', '11.1.2' # pinned to accommodate rubocop 0.32.1
  s.add_development_dependency 'rspec-core'
  s.add_development_dependency 'rspec-expectations'
  s.add_development_dependency 'rspec-mocks'
  s.add_development_dependency 'rubocop', '~> 0.32.1'

  s.files = `git ls-files`.split($INPUT_RECORD_SEPARATOR)
  s.executables = s.files.grep(/^bin\//) { |f| File.basename(f) }
  s.test_files = s.files.grep(/^(test|spec|features)\//)
  s.require_path = 'lib'
end
