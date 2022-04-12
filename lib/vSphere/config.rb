# frozen_string_literal: true

require 'vagrant'

module VagrantPlugins
  module VSphere
    class Config < Vagrant.plugin('2', :config)
      attr_accessor :ip_address_timeout, :host, :insecure, :user, :password, :data_center_name, :compute_resource_name, :resource_pool_name, :clone_from_vm, :template_name, :name, :vm_base_path, :customization_spec_name, :data_store_name, :linked_clone, :proxy_host, :proxy_port, :vlan, :addressType, :mac, :memory_mb, :cpu_count, :cpu_reservation, :mem_reservation, :extra_config, :real_nic_ip, :notes, :wait_for_sysprep # Time to wait for an IP address when booting, in seconds @return [Integer]

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

        self.password = machine.ui.ask('vSphere Password (will be hidden): ', echo: false) if password == :ask || password.nil?

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
