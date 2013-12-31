require 'vagrant'

module VagrantPlugins
  module VSphere
    class Config < Vagrant.plugin('2', :config)
      attr_accessor :host
      attr_accessor :insecure
      attr_accessor :user
      attr_accessor :password
      attr_accessor :data_center_name
      attr_accessor :compute_resource_name
      attr_accessor :resource_pool_name
      attr_accessor :clone_from_vm
      attr_accessor :template_name
      attr_accessor :name
      attr_accessor :customization_spec_name
      attr_accessor :data_store_name

      def validate(machine)
        errors = _detected_errors

        #TODO: add blank?
        errors << I18n.t('config.host') if host.nil?
        errors <<  I18n.t('config.user') if user.nil?
        errors <<  I18n.t('config.password') if password.nil?
        if name.nil?
          prefix = "#{machine.name}"
          prefix.gsub!(/[^-a-z0-9_]/i, "")
          # milliseconds + random number suffix to allow for simultaneous `vagrant up` of the same box in different dirs
          machine.provider_config.name = prefix + "_#{(Time.now.to_f * 1000.0).to_i}_#{rand(100000)}"
        end
        errors <<  I18n.t('config.template') if template_name.nil?

        #These are only required if we're cloning from an actual template
        errors << I18n.t('config.compute_resource') if compute_resource_name.nil? and not clone_from_vm
        errors << I18n.t('config.resource_pool') if resource_pool_name.nil? and not clone_from_vm

        { 'vSphere Provider' => errors }
      end
    end
  end
end
