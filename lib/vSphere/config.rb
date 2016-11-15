require 'vagrant'

module VagrantPlugins
  module VSphere
    class Config < Vagrant.plugin('2', :config)

      class NetworkConfiguration
        attr_accessor :allowGuestControl
        attr_accessor :connected
        attr_accessor :startConnected

        attr_accessor :vlan
        attr_accessor :addressType
        attr_accessor :macAddress
        attr_accessor :wakeOnLanEnabled

        def initialize(network_config)
          @allowGuestControl = false
          @connected = true
          @startConnected = true

          @vlan = nil
          @addressType = 'generated'
          @macAddress = nil
          @wakeOnLanEnabled = false

          @allowGuestControl = network_config[:allowGuestControl] if network_config.key?(:allowGuestControl)
          @connected = network_config[:connected] if network_config.key?(:connected)
          @startConnected = network_config[:startConnected] if network_config.key?(:startConnected)
          @vlan = network_config[:vlan] if network_config.key?(:vlan)
          @addressType = network_config[:addressType] if network_config.key?(:addressType)
          @macAddress = network_config[:macAddress] if network_config.key?(:macAddress)
          @wakeOnLanEnabled = network_config[:wakeOnLanEnabled] if network_config.key?(:wakeOnLanEnabled)
        end
      end

      class SerialPortConfiguration
          attr_accessor :yieldOnPoll
          attr_accessor :connected
          attr_accessor :startConnected          
          attr_accessor :backing

          attr_accessor :direction
          attr_accessor :proxyURI
          attr_accessor :serviceURI

          attr_accessor :endpoint
          attr_accessor :noRxLoss

          attr_accessor :fileName

          attr_accessor :deviceName
          attr_accessor :useAutoDetect          

          def initialize(serial_port_config)
            @yieldOnPoll = true
            @connected = true
            @startConnected = true            
            @backing = ''

            @direction = ''
            @proxyURI = ''
            @serviceURI = ''

            @endpoint = ''
            @noRxLoss = true            

            @fileName = ''

            @deviceName = ''
            @useAutoDetect = false            

            @yieldOnPoll = serial_port_config[:yieldOnPoll] if serial_port_config.key?(:yieldOnPoll)
            @connected = network_config[:connected] if network_config.key?(:connected)
            @startConnected = network_config[:startConnected] if network_config.key?(:startConnected)            
            @backing = serial_port_config[:backing] if serial_port_config.key?(:backing)
            if !(@backing == 'uri' || @backing == 'pipe' || @backing == 'file' || @backing == 'device')
              raise "The only valid values allowed for backing are 'uri', 'pipe', 'file', 'device'"
            end

            @direction = serial_port_config[:direction] if serial_port_config.key?(:direction)
            if @backing == 'uri' && !(@direction == 'client' || @direction == 'server')
              raise "The only valid values allowed for direction are 'client', 'server'"
            end
            @proxyURI = serial_port_config[:proxyURI] if serial_port_config.key?(:proxyURI)
            @serviceURI = serial_port_config[:serviceURI] if serial_port_config.key?(:serviceURI)

            @endpoint = serial_port_config[:endpoint] if serial_port_config.key?(:endpoint)
            if @backing == 'pipe' && !(@endpoint == 'client' || @endpoint == 'server')
              raise "The only valid values allowed for endpoint are 'client', 'server'"
            end            
            @noRxLoss = serial_port_config[:noRxLoss] if serial_port_config.key?(:noRxLoss)

            @fileName = serial_port_config[:fileName] if serial_port_config.key?(:fileName)

            @deviceName = serial_port_config[:deviceName] if serial_port_config.key?(:deviceName)
            @useAutoDetect = serial_port_config[:useAutoDetect] if serial_port_config.key?(:useAutoDetect)
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

      attr_accessor :real_nic_ip

      attr_accessor :destroy_unused_network_interfaces
      attr_accessor :destroy_unused_serial_ports
      attr_reader   :network_adapters
      attr_reader   :serial_ports
      attr_reader   :custom_attributes

      def initialize
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
