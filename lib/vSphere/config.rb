require 'vagrant'

module VagrantPlugins
  module VSphere
    class Config < Vagrant.plugin('2', :config)

      class NetworkConfiguration
        attr_accessor :allow_guest_control
        attr_accessor :connected
        attr_accessor :start_connected

        attr_accessor :vlan
        attr_accessor :address_type
        attr_accessor :mac_address
        attr_accessor :ip_address
        attr_accessor :wake_on_lan_enabled

        def initialize(network_config)
          @allow_guest_control = false
          @connected = true
          @start_connected = true

          @vlan = nil
          @address_type = 'generated'
          @mac_address = nil
          @ip_address = nil
          @wake_on_lan_enabled = false

          @allow_guest_control = network_config[:allow_guest_control] if network_config.key?(:allow_guest_control)
          @connected = network_config[:connected] if network_config.key?(:connected)
          @start_connected = network_config[:start_connected] if network_config.key?(:start_connected)
          @vlan = network_config[:vlan] if network_config.key?(:vlan)
          @address_type = network_config[:address_type] if network_config.key?(:address_type)
          @mac_address = network_config[:mac_address].tr(' |-', '').gsub(/(..)(..)(..)(..)(..)(..)/, '\1:\2:\3:\4:\5:\6') if network_config.key?(:mac_address)
          @address_type = 'manual' if network_config.key?(:mac_address)
          @ip_address = network_config[:ip_address] if network_config.key?(:ip_address)
          @wake_on_lan_enabled = network_config[:wake_on_lan_enabled] if network_config.key?(:wake_on_lan_enabled)
        end
      end

      class SerialPortConfiguration
          attr_accessor :yield_on_poll
          attr_accessor :connected
          attr_accessor :start_connected
          attr_accessor :backing

          attr_accessor :direction
          attr_accessor :proxy_uri
          attr_accessor :service_uri

          attr_accessor :endpoint
          attr_accessor :no_rx_loss

          attr_accessor :file_name

          attr_accessor :device_name
          attr_accessor :use_auto_detect

          def initialize(serial_port_config)
            @yield_on_poll = true
            @connected = true
            @start_connected = true
            @backing = ''

            @direction = ''
            @proxy_uri = ''
            @service_uri = ''

            @endpoint = ''
            @no_rx_loss = true

            @file_name = ''

            @device_name = ''
            @use_auto_detect = false

            @yield_on_poll = serial_port_config[:yield_on_poll] if serial_port_config.key?(:yield_on_poll)
            @connected = network_config[:connected] if network_config.key?(:connected)
            @start_connected = network_config[:start_connected] if network_config.key?(:start_connected)
            @backing = serial_port_config[:backing] if serial_port_config.key?(:backing)
            if !(@backing == 'uri' || @backing == 'pipe' || @backing == 'file' || @backing == 'device')
              raise "The only valid values allowed for backing are 'uri', 'pipe', 'file', 'device'"
            end

            @direction = serial_port_config[:direction] if serial_port_config.key?(:direction)
            if @backing == 'uri' && !(@direction == 'client' || @direction == 'server')
              raise "The only valid values allowed for direction are 'client', 'server'"
            end
            @proxy_uri = serial_port_config[:proxy_uri] if serial_port_config.key?(:proxy_uri)
            @service_uri = serial_port_config[:service_uri] if serial_port_config.key?(:service_uri)

            @endpoint = serial_port_config[:endpoint] if serial_port_config.key?(:endpoint)
            if @backing == 'pipe' && !(@endpoint == 'client' || @endpoint == 'server')
              raise "The only valid values allowed for endpoint are 'client', 'server'"
            end            
            @no_rx_loss = serial_port_config[:no_rx_loss] if serial_port_config.key?(:no_rx_loss)

            @file_name = serial_port_config[:file_name] if serial_port_config.key?(:file_name)

            @device_name = serial_port_config[:device_name] if serial_port_config.key?(:device_name)
            @use_auto_detect = serial_port_config[:use_auto_detect] if serial_port_config.key?(:use_auto_detect)
          end
      end

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
      attr_accessor :memory_mb
      attr_accessor :cpu_count
      attr_accessor :cpu_reservation
      attr_accessor :mem_reservation
      attr_accessor :extra_config
      attr_accessor :notes
      attr_accessor :wait_for_customization
      attr_accessor :wait_for_customization_timeout

      attr_accessor :destroy_unused_network_interfaces
      attr_accessor :destroy_unused_serial_ports
      attr_accessor :management_network_adapter_slot
      attr_accessor :management_network_adapter_address_family
      attr_reader   :network_adapters
      attr_reader   :serial_ports
      attr_reader   :custom_attributes

      def initialize
        @wait_for_customization_timeout = 600
        @destroy_unused_network_interfaces = UNSET_VALUE
        @destroy_unused_serial_ports = UNSET_VALUE
        @network_adapters  = {}
        @custom_attributes = {}
        @serial_ports = {}
        @extra_config = {}
      end

      def custom_attribute(key, value)
        @custom_attributes[key.to_sym] = value
      end

      def network_adapter(slot, **opts)
        @network_adapters[slot] = NetworkConfiguration.new opts
      end

      def serial_port(slot, **opts)
        @serial_ports[slot] = SerialPortConfiguration.new opts
      end

      def finalize!
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
