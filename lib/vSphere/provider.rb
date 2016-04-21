require 'vagrant'

module VagrantPlugins
  module VSphere
    class Provider < Vagrant.plugin('2', :provider)
      def initialize(machine)
        @machine = machine
      end

      def action(name)
        action_method = "action_#{name}"
        return Action.send(action_method) if Action.respond_to?(action_method)
        nil
      end

      def ssh_info
        env = @machine.action('get_ssh_info', lock: false)
        env[:machine_ssh_info]
      end

      def state
        env = @machine.action('get_state', lock: false)

        state_id = env[:machine_state_id]

        short = "vagrant_vsphere.states.short_#{state_id}"
        long  = "vagrant_vsphere.states.long_#{state_id}"

        # Return the MachineState object
        Vagrant::MachineState.new(state_id, short, long)
      end

      def to_s
        id = @machine.id.nil? ? 'new' : @machine.id
        "vSphere (#{id})"
      end
    end
  end
end
