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

  # force the use of Nokogiri 1.5.x to prevent conflicts with older versions of zlib
  s.add_dependency 'nokogiri', '~>1.5'
  # force the use of rbvmomi 1.8.2 to work around concurrency errors: https://github.com/nsidc/vagrant-vsphere/issues/139
  s.add_dependency 'rbvmomi', '~> 1.8.2'
  s.add_dependency 'i18n', '>= 0.6.4', '< 0.8.0'

  s.add_development_dependency 'rake'
  s.add_development_dependency 'rspec-core'
  s.add_development_dependency 'rspec-expectations'
  s.add_development_dependency 'rspec-mocks'
  s.add_development_dependency 'rubocop', '~> 0.32.1'

  s.files = `git ls-files`.split($INPUT_RECORD_SEPARATOR)
  s.executables = s.files.grep(/^bin\//) { |f| File.basename(f) }
  s.test_files = s.files.grep(/^(test|spec|features)\//)
  s.require_path = 'lib'
end
