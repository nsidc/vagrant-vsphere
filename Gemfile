source 'http://rubygems.org'

gemspec

group :development do
  # We depend on Vagrant for development, but we don't add it as a
  # gem dependency because we expect to be installed within the
  # Vagrant environment itself using `vagrant plugin`.

  ruby '2.0.0'
  gem 'vagrant', git: 'git://github.com/mitchellh/vagrant.git', tag: 'v1.8.1'
end

group :plugins do
  gem 'vagrant-vsphere', path: '.'
end
