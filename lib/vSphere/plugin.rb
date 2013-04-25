require 'vagrant'

module VagrantPlugins
  module VSphere
    class Plugin < Vagrant.plugin('2')
      name 'vsphere'
      description 'Allows Vagrant to manage machines with VMWare vSphere'

      config(:vsphere, :provider) do
        require_relative 'config'
        Config
      end

      provider(:vsphere) do
        # TODO: add logging
        setup_i18n

        # Return the provider
        require_relative 'provider'
        Provider
      end


      def self.setup_i18n
        I18n.load_path << File.expand_path('locales/en.yml', VSphere.source_root)
        I18n.reload!
      end
    end
  end
end