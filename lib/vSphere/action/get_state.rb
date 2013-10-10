require 'rbvmomi'
require 'vSphere/util/vim_helpers'

module VagrantPlugins
  module VSphere
    module Action
      class GetState
        include Util::VimHelpers

        # the three possible values of a vSphere VM's power state
        POWERED_ON = 'poweredOn'
        POWERED_OFF = 'poweredOff'
        SUSPENDED = 'suspended'

        def initialize(app, env)
          @app = app
        end

        def call(env)
          env[:machine_state_id] = get_state(env[:vSphere_connection], env[:machine])

          @app.call env
        end

        private

        def get_state(connection, machine)
          return :not_created  if machine.id.nil?

          vm = get_vm_by_uuid connection, machine

          if vm.nil?
            return :not_created
          end

          if vm.runtime.powerState.eql?(POWERED_ON)
            :running
          else
            # If the VM is powered off or suspended, we consider it to be powered off. A power on command will either turn on or resume the VM
            :poweroff
          end
        end
      end
    end
  end
end