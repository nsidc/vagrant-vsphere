require 'vagrant'

module VagrantPlugins
  module VSphere
    class Config < Vagrant.plugin('2', :config)
      attr_accessor :ip_address_timeout # Time to wait for an IP address when booting, in seconds @return [Integer]
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
      attr_accessor :extra_config
      attr_accessor :real_nic_ip
      attr_accessor :notes
      attr_accessor :wait_for_sysprep
      attr_accessor :disk_size

      attr_reader :custom_attributes

      def initialize
        @ip_address_timeout = UNSET_VALUE
        @wait_for_sysprep = UNSET_VALUE
        @custom_attributes = {}
        @extra_config = {}
      end

      def finalize!
        @ip_address_timeout = 240 if @ip_address_timeout == UNSET_VALUE
        @wait_for_sysprep = false if @wait_for_sysprep == UNSET_VALUE
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
