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
      attr_accessor :vm_base_path
      attr_accessor :customization_spec_name
      attr_accessor :data_store_name
      attr_accessor :linked_clone
      attr_accessor :proxy_host
      attr_accessor :proxy_port
      attr_accessor :vlan
      attr_accessor :addressType
      attr_accessor :mac
      attr_accessor :memory_mb
      attr_accessor :cpu_count
      attr_accessor :cpu_reservation
      attr_accessor :mem_reservation

      attr_reader :custom_attributes

      def initialize
        @custom_attributes = {}
      end

      def custom_attribute(key, value)
        @custom_attributes[key.to_sym] = value
      end

      def validate(machine)
        errors = _detected_errors

        if password == :ask || password.nil?
          self.password = machine.ui.ask('vSphere Password (will be hidden): ', echo: false)
        end

        # TODO: add blank?
        errors << I18n.t('vsphere.config.host') if host.nil?
        errors <<  I18n.t('vsphere.config.user') if user.nil?
        errors <<  I18n.t('vsphere.config.password') if password.nil?
        errors <<  I18n.t('vsphere.config.template') if template_name.nil?

        # Only required if we're cloning from an actual template
        errors << I18n.t('vsphere.config.compute_resource') if compute_resource_name.nil? && !clone_from_vm

        { 'vSphere Provider' => errors }
      end
    end
  end
end
