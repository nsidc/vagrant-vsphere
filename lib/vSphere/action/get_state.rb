require 'rbvmomi'
require 'vSphere/util/vim_helpers'
require 'vSphere/util/vm_helpers'

module VagrantPlugins
  module VSphere
    module Action
      class GetState
        include Util::VimHelpers
        include Util::VmHelpers

        def initialize(app, _env)
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

          return :not_created if vm.nil?

          if powered_on?(vm)
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
