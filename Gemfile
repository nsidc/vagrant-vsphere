source 'http://rubygems.org'

gemspec

group :development do
  # We depend on Vagrant for development, but we don't add it as a
  # gem dependency because we expect to be installed within the
  # Vagrant environment itself using `vagrant plugin`.

  if RUBY_VERSION < "2.0.0" then
    puts "Found old ruby #{RUBY_VERSION}, using old vagrant (v1.4.3)"
    gem 'vagrant', :git => 'git://github.com/mitchellh/vagrant.git', :tag => 'v1.4.3'
  else
    gem 'vagrant', :git => 'git://github.com/mitchellh/vagrant.git'
  end
end
