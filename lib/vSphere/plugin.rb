begin
  require 'vagrant'
rescue LoadError
  raise 'The Vagrant vSphere plugin must be run within Vagrant.'
end

# This is a sanity check to make sure no one is attempting to install
# this into an early Vagrant version.
if Vagrant::VERSION < '1.5'
  fail 'The Vagrant vSphere plugin is only compatible with Vagrant 1.5+'
end

module VagrantPlugins
  module VSphere
    class Plugin < Vagrant.plugin('2')
      name 'vsphere'
      description 'Allows Vagrant to manage machines with VMWare vSphere'

      config(:vsphere, :provider) do
        require_relative 'config'
        Config
      end

      provider(:vsphere, parallel: true) do
        # TODO: add logging
        setup_i18n

        # Return the provider
        require_relative 'provider'
        Provider
      end

      provider_capability('vsphere', 'public_address') do
        require_relative 'cap/public_address'
        Cap::PublicAddress
      end

      def self.setup_i18n
        I18n.load_path << File.expand_path('locales/en.yml', VSphere.source_root)
        I18n.reload!
      end
    end
  end
end
