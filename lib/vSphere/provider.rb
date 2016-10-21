require 'log4r'
require 'vagrant'
require_relative 'driver'

module VagrantPlugins
  module VSphere
    class Provider < Vagrant.plugin('2', :provider)
      attr_reader :driver

      def initialize(machine)
        @logger = Log4r::Logger.new('vagrant::provider::vsphere')
        @machine = machine
        
        # This method will load in our driver, so we call it now to
        # initialize it.
        machine_id_changed
      end

      def action(name)
        action_method = "action_#{name}"
        return Action.send(action_method) if Action.respond_to?(action_method)
        nil
      end

      # If the machine ID changed, then we need to rebuild our underlying
      # driver.
      def machine_id_changed
        id = @machine.id
        @logger.debug("Instantiating the driver for machine ID: #{@machine.id.inspect}")
        @driver = VagrantPlugins::VSphere::Driver.new(@machine)
        nil
      end

      def driver
        return @driver if @driver
        @driver = VagrantPlugins::VSphere::Driver.new(@machine)
      end

      def ssh_info
        driver.ssh_info
      end

      def state
        # Determine the ID of the state here.
        state_id = @driver.state

        # Translate into short/long descriptions
        short = state_id.to_s.gsub('_', ' ')
        long  = I18n.t("vagrant_vsphere.commands.status.#{state_id}")

        # If machine is not created, then specify the special ID flag
        if state_id == :not_created
          state_id = Vagrant::MachineState::NOT_CREATED_ID
        end

        # Return the state
        Vagrant::MachineState.new(state_id, short, long)
      end

      def to_s
        id = @machine.id.nil? ? 'new' : @machine.id
        "vSphere (#{id})"
      end
    end
  end
end